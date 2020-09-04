#! /usr/bin/env python3

from enum import Enum
import argparse
import json
import os
import os.path

class FilesystemType(Enum):
    EXT2 = "ext2"
    EXT3 = "ext3"
    EXT4 = "ext4"
    FAT32 = "fat32"

    def toCommand(self):
        commandMap = {FilesystemType.EXT2: "mkfs.ext2",
                      FilesystemType.EXT3: "mkfs.ext3",
                      FilesystemType.EXT4: "mkfs.ext4",
                      FilesystemType.FAT32: "mkfs.fat -F32"}
        return commandMap[self]
    
    @staticmethod
    def fromString(fstype):
        try:
            return FilesystemType(fstype)
        except ValueError:
            print(fstype + " is not a supported filesystem type, defaulting to ext4")
            return FilesystemType.EXT4

class ImageDefinition:
    def __init__(self, jsonFile=None):
        if jsonFile is None:
            self.path = "output/"
            self.name = "rootfs.img"
            self.fstype = FilesystemType.EXT4
            self.isSparse = True
            self.doMount = True
            self.mountPoint = "mount/"
            self.sizeInMB = 2048
            return

        if os.path.exists(jsonFile):
            try:
                with open(jsonFile) as f:
                    image_config = json.load(f)
                    if image_config is not None:
                        self.path = image_config["path"] if image_config.get("path") is not None else "output/"
                        self.name = image_config["name"] if image_config.get("name") is not None else "rootfs.img"
                        self.fstype = FilesystemType.fromString(image_config["fstype"]) if image_config.get("fstype") is not None else FilesystemType.EXT4
                        self.isSparse = image_config["isSparse"] if image_config.get("isSparse") is not None else True
                        self.doMount = image_config["doMount"] if image_config.get("doMount") is not None else True
                        self.mountPoint = image_config["mountPoint"] if image_config.get("mountPoint") is not None else "mount/"
                        self.sizeInMB = image_config["sizeInMB"] if image_config.get("sizeInMB") is not None else 2048
            except ValueError:
                print("Failed to decode image spec file. Ensure it's valid json.")
            except OSError:
                print("Something went wrong")
                raise      
        else:
            print("Failed to find image spec json file (" + jsonFile + ")")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--spec", help="Specify image spec json file.", metavar="FILE", nargs=1, default="config/image.json")
    parser.add_argument("--only-mount", help="Skip image creation and mount existing image.", action="store_true")
    parser.add_argument("--unmount", help="Helper function to unmount specified image.", action="store_true")
    args = vars(parser.parse_args())
    #print (args)
    targetImage = ImageDefinition(args["spec"][0])
    targetImagePath = targetImage.path + "/" + targetImage.name
    if args["unmount"]:
        os.system("umount " + targetImage.mountPoint)
        exit(0)

    if not args["only_mount"]:
        dd_count = targetImage.sizeInMB if not targetImage.isSparse else 0
        dd_seek = targetImage.sizeInMB if targetImage.isSparse else 0
        dd_cmd = "dd if=/dev/zero of=" + targetImagePath + " bs=1M count=" + str(dd_count) + " seek=" + str(dd_seek)
        #print (dd_cmd)
        os.system(dd_cmd)
        mkfs_cmd = targetImage.fstype.toCommand() + " " + targetImagePath
        #print (mkfs_cmd)
        os.system(mkfs_cmd)
    
    if args["only_mount"] or targetImage.doMount:
        mount_cmd = "mount -o loop -t " + targetImage.fstype.value + " " + targetImagePath + " " + targetImage.mountPoint
        #print (mount_cmd)
        os.system(mount_cmd)