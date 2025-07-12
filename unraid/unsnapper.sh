#!/bin/bash

DEBUG=${DEBUG:-false}
DRY_RUN=${DRY_RUN:-false}

# The number of snapshots we are going to keep per share
SNAPSHOT_LIMIT=12
SHARE_MOUNTPOINT=/mnt/.user
# Change this array to include your shares
# NOTE: Currently we cannot snapshot shares that are under a cache
# This is simply because we don't have a good way of determining which
# disks are your cache disks. You could probably add some logic to account for that
# but since I am not using cache, I don't care
UNRAID_SHARES=("filepool" "vm-fatpool" "mediapool" "vm-fastpool")
now=$(date +%Y%m%d%H%M%S)

# Function to show usage
function usage() {
    cat << EOF
Usage: $0 [OPTIONS]

If no options are provided, this script will create new snapshots and then clean lingering ones

NOTE: Currently this does not support snapshotting shares that have a cache pool in front of them
NOTE: If you are planning on mounting the SHARE_MOUNTPOINT in a docker container, you will need to ensure
      the mountpoint is mounted with the ":shared" flag. EG --volume /mnt/.user:/shares:shared
      See: https://docs.docker.com/engine/storage/bind-mounts/#configure-bind-propagation for details

OPTIONS:
    -v, --verbose    Enable debug/verbose output
    -d, --dry        Enable dry run mode (don't execute commands)
    -c, --clean      Cleanup lingering snapshots
    -s, --snap       Create new snapshots
    -u, --update     Relinks all latest snapshots and updates various mergerfs shares
    -h, --help       Show this help message

ENVIRONMENT VARIABLES:
    DEBUG=true       Enable debug output (same as -v)
    DRY_RUN=true     Enable dry run mode (same as -d)
EOF
}

function error(){
  echo -e "\033[1;31m$(date '+%Y-%m-%d %H:%M:%S') - $@\033[0m"
}

function debug(){
  [ "${DEBUG}" != "true" ] && return 0
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $@"
}

function log(){
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $@"
}

function _snapshot_btrfs_disk(){
    local disk="${1}"
    local share="${2}"
    debug "Creating BTRFS snapshot of disk ${disk}"
    if [ ! -d "${disk}/.snapshots" ]; then
        debug "Creating hidden snapshot directory in ${disk} so we can mount our snapshot there"
        if [ "${DRY_RUN}" != true ]; then
            btrfs subvolume create "${disk}/.snapshots" 2>/dev/null
        else
            debug "Would have executed 'btrfs subvolume create \"${disk}/.snapshots\" 2>/dev/null'"
        fi
    fi
    local snapshot_name="${now}"
    if [ -d "${disk}/.snapshots/${snapshot_name}" ]; then
        debug "Our snapshot (${snapshot_name}) already exists on ${disk}"
        return
    fi
    if [ "${DRY_RUN}" != true ]; then
        mkdir -p "${disk}/.snapshots" 2>/dev/null
        btrfs subvolume snapshot -r "${disk}" "${disk}/.snapshots/${snapshot_name}"
    else
        debug "Would have executed 'mkdir -p \"${disk}/.snapshots/${snapshot_name}\"'"
        debug "Would have executed 'btrfs subvolume snapshot -r \"${disk}\" \"${disk}/.snapshots/${snapshot_name}\"'"
    fi
}

function _delete_btrfs_snapshot(){
    local disk="${1}"
    local share="${2}"
    local snapshot_dir="${disk}/.snapshots"
    debug "Getting snapshots in ${snapshot_dir}"
    snapshots=($(btrfs subvolume list -s "${disk}" | grep -oE '.snapshots/[0-9]+' | cut -d '/' -f 2 | sort -r | tail +$((SNAPSHOT_LIMIT+1)) ))
    for snapshot in "${snapshots[@]}"; do
        debug "Removing expired BTRFS snapshot ${snapshot}"
        if [ -d "${SHARE_MOUNTPOINT}/${share}/${snapshot}" ]; then
            local mount_point="${SHARE_MOUNTPOINT}/${share}/${snapshot}"
            debug "Unmounting snapshot before destroying it"
            if [ "${DRY_RUN}" != true ]; then
                umount "${mount_point}"
                rmdir "${mount_point}"
            else
                debug "Would have executed 'umount \"${SHARE_MOUNTPOINT}/${share}/${snapshot}\"'"
                debug "Would have executed 'rmdir \"${SHARE_MOUNTPOINT}/${share}/${snapshot}\"'"
            fi
        fi
        if [ "${DRY_RUN}" != true ]; then
            btrfs subvolume delete "${disk}/.snapshots/${snapshot}"
        else
            debug "Would have executed 'btrfs subvolume delete \"${disk}/.snapshots/${snapshot}\"'"
        fi
    done
}

function _snapshot_zfs_pool(){
    local pool="${1}"
    debug "Creating ZFS snapshot of pool ${pool}"
    if [ "${DRY_RUN}" != true ]; then
        zfs snapshot "${pool}@${now}"
    else
        debug "Would have executed 'zfs snapshot \"${pool}@${now}\"'"
    fi
}

function _delete_zfs_snapshot(){
    local pool="${1}"
    local share="${2}"
    debug "Fetching snapshots for ${pool}"
    snapshots=($(zfs list -t snap | grep "${pool}" | grep -oE "${pool}@[0-9]+"| sed --expression "s|${pool}@||g"| sort -r | tail +$((SNAPSHOT_LIMIT+1)) ))
    for snapshot in "${snapshots[@]}"; do
        if mount 2>&1 | grep -q "${pool}@${snapshot}"; then
            debug "Snapshot ${pool}@${snapshot} is mounted, unmounting it first"
            if [ "${DRY_RUN}" != true ]; then
                umount "${pool}@${snapshot}"
            else
                debug "Would have executed 'umount \"${pool}@${snapshot}\"'"
            fi
        fi
        if [ -d "${SHARE_MOUNTPOINT}/${share}/${snapshot}" ]; then
            debug "Unmounting snapshot before destroying it"
            local mount_point="${SHARE_MOUNTPOINT}/${share}/${snapshot}"
            if [ "${DRY_RUN}" != true ]; then
                umount "${mount_point}"
                rmdir "${mount_point}"
            else
                debug "Would have executed 'umount \"${SHARE_MOUNTPOINT}/${share}/${snapshot}\"'"
                debug "Would have executed 'rmdir \"${SHARE_MOUNTPOINT}/${share}/${snapshot}\"'"
            fi
        fi
        debug "Removing expired ZFS snapshot ${pool}@${snapshot}"
        if [ "${DRY_RUN}" != true ]; then
            zfs destroy "${pool}@${snapshot}"
        else
            debug "Would have executed 'zfs destroy \"${pool}@${snapshot}\"'"
        fi
    done
}

function _snapshot_share(){
    local share="${1}"
    local clean_only="${2}"
    debug "Finding backing disks for ${share}"
    if [ ! -z "${clean_only}" ]; then
        log "Only cleaning orphaned snapshots for ${share}"
    fi
    local backing_disks=($(find /mnt -type d -name "${share}" -maxdepth 2 -mindepth 1 | grep -vE 'user0?' | sed --expression "s|/${share}||g"))
    for backing_disk in "${backing_disks[@]}"; do
        local disk_fs_type=$(mount | grep -E "on ${backing_disk}" | sed --expression 's/^.*type\s\(btrfs\|zfs\|xfs\).*$/\1/g' | uniq | head -n 1)
        if [ -z "${disk_fs_type}" ]; then
            error "Unable to determine the filesystem on ${backing_disk}"
            return 10
        fi
        if [ "${disk_fs_type}" == "zfs" ]; then
            # if its zfs, we need to do a bit more to figure out the actual pool we need to snapshot
            local zfs_disk=$(zfs list | grep "${share}" | awk '{print $1}' | head -n 1)
            # Bash doesn't like nested ifs so this is how we are doing it instead
            [ -z "${clean_only}" ] && _snapshot_zfs_pool "${zfs_disk}"
            _delete_zfs_snapshot "${zfs_disk}" "${share}"
        elif [ "${disk_fs_type}" == "btrfs" ]; then
            [ -z "${clean_only}" ] && _snapshot_btrfs_disk "${backing_disk}"
            _delete_btrfs_snapshot "${backing_disk}" "${share}"
        else
            error "Filesystem \"${disk_fs_type}\" does not support snapshotting"
            return 11
        fi
    done
}

function _find_most_recent_share_snapshot(){
    local share="${1}"
    local share_snapshot="${SHARE_MOUNTPOINT}/${share}"
    local backing_disks=($(find /mnt -type d -name "${share}" -maxdepth 2 -mindepth 1 | grep -vE 'user0?' | sed --expression "s|/${share}||g"))
    local snapshot_dir=""
    for disk in "${backing_disks[@]}"; do
        if [ -d "${disk}/${share}/.zfs/snapshot" ]; then
            # Assume the share is zfs
            snapshot_dir="${disk}/${share}/.zfs/snapshot"
        elif [ -d "${disk}/.snapshots" ]; then
            # Assume the disk is btrfs
            snapshot_dir="${disk}/.snapshots"
        fi
    done
    if [ -z "${snapshot_dir}" ]; then
        error "Unable to locate snapshot directory for \"${share}\""
        return 10
    fi
    local most_recent_snapshot=$(find "${snapshot_dir}" -maxdepth 1 -mindepth 1 -type d | sort -r | rev | cut -d '/' -f 1 | rev | head -n 1)
    echo "${most_recent_snapshot}"
}

function _merge_snapshots(){
    local share="${1}"
    local snapshot="${2}"
    local share_mount="${SHARE_MOUNTPOINT}/${share}/${snapshot}"
    debug "Merging all snapshots on ${snapshot} and mounting them at ${share_mount}"
    local backing_disks=($(find /mnt -type d -name "${share}" -maxdepth 2 -mindepth 1 | grep -vE 'user0?' | sed --expression "s|/${share}||g"))

    if [ "${DRY_RUN}" != true ]; then
        mkdir -p "${share_mount}" 2>/dev/null
    else
        debug "Would have executed 'mkdir -p \"${share_mount}\"'"
    fi

    local merged_disks=""
    for disk in "${backing_disks[@]}"; do
        if [ -d "${disk}/${share}/.zfs/snapshot/${snapshot}" ]; then
            merged_disks="${merged_disks}${disk}/${share}/.zfs/snapshot/${snapshot}:"
        else
            merged_disks="${merged_disks}${disk}/.snapshots/${snapshot}/${share}:"
        fi
    done
    merged_disks=${merged_disks%?}
    if [ "${DRY_RUN}" != true ]; then
        mergerfs "${merged_disks}" "${share_mount}"
    else
        debug "Would have executed 'mergerfs \"${merged_disks}\" \"${share_mount}\"'"
    fi

    log "Created merged snapshot ${snapshot} of ${share} and mounted it on ${share_mount}"
}

function snapshot(){
    log "Creating Snapshots"
    for share in "${UNRAID_SHARES[@]}"; do
        _snapshot_share "${share}"
    done
}

function cleanup(){
    log "Cleaning up old snapshots"
    for share in "${UNRAID_SHARES[@]}"; do
        _snapshot_share "${share}" true
    done
}

function update_latest(){
    log "Updating the current latest share snapshot"
    if [ "${DRY_RUN}" != true ]; then
        mkdir -p "${SHARE_MOUNTPOINT}" 2>/dev/null
    else
        debug "Would have executed 'mkdir -p \"${SHARE_MOUNTPOINT}\"'"
    fi
    debug "Gathering snapshots"
    for share in "${UNRAID_SHARES[@]}"; do
        local share_snapshot="${SHARE_MOUNTPOINT}/${share}"
        if [[ ! -d "${share_snapshot}" ]] &&  [[ "${DRY_RUN}" != true ]]; then
            mkdir -p "${share_snapshot}"
        else
            debug "Would have executed 'mkdir -p \"${share_snapshot}\"'"
        fi
        local most_recent_snapshot=$(_find_most_recent_share_snapshot "${share}")
        debug "Most recent snapshot for ${share} is ${most_recent_snapshot}"
        if [ "${DRY_RUN}" != true ]; then
            mkdir -p "${SHARE_MOUNTPOINT}/${share}/${most_recent_snapshot}"
        else
            debug "Would have executed 'mkdir -p \"${SHARE_MOUNTPOINT}/${share}/${most_recent_snapshot}\"'"
        fi
        _merge_snapshots "${share}" "${most_recent_snapshot}"
        if [ -L "${SHARE_MOUNTPOINT}/${share}/latest" ]; then
            # We need to remove the symlink
            if [ "${DRY_RUN}" != true ]; then
                debug "Removing previous latest symlink"
                rm "${SHARE_MOUNTPOINT}/${share}/latest"
            else
                debug "Would have executed 'rm \"${SHARE_MOUNTPOINT}/${share}/latest\"'"
            fi
        fi
        if [ -d "${SHARE_MOUNTPOINT}/${share}/latest" ]; then
            if mount | grep -q "${SHARE_MOUNTPOINT}/${share}/latest"; then
                # We need to unmount the latest share
                debug "Previous latest snapshot of ${share} is still mounted, attempting to unmount it"
                if [ "${DRY_RUN}" != true ]; then
                    umount "${SHARE_MOUNTPOINT}/${share}/latest"
                else
                    debug "Would have executed 'umount \"${SHARE_MOUNTPOINT}/${share}/latest\"'"
                fi
            fi
        fi
        log "Mounting latest snapshot of ${share}"
        if [ "${DRY_RUN}" != true ]; then
            mkdir -p "${SHARE_MOUNTPOINT}/${share}/latest"
            mount --bind -o ro, "${SHARE_MOUNTPOINT}/${share}/${most_recent_snapshot}" "${SHARE_MOUNTPOINT}/${share}/latest"
        else
            debug "Would have executed 'mkdir \"${SHARE_MOUNTPOINT}/${share}/latest\"'"
            debug "Would have executed 'mount --bind -o ro, \"${SHARE_MOUNTPOINT}/${share}/${most_recent_snapshot}\" \"${SHARE_MOUNTPOINT}/${share}/latest\"'"
        fi
    done
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            DEBUG=true
            shift
            ;;
        -d|--dry)
            DRY_RUN=true
            DEBUG=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -c|--clean)
            cleanup
            exit 0
            ;;
        -s|--snap)
            snapshot
            exit 0
            ;;
        -u|--update)
            update_latest
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            exit 1
            ;;
    esac
done

function _check(){
    if ! command -v mergerfs >/dev/null; then
        error "Mergerfs needs to be installed and on the path in order for us to snapshot shares!"
        exit 10
    fi
}

function main(){
    _check
    snapshot
    cleanup
    update_latest
    log "Unsnapper completed"
}

# Run main function
main
exit 0
