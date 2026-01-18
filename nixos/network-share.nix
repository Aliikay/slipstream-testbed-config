{ }:
{
  fileSystems."/home/slipstream-testbed/slipstream-share" = {
    device = "slipstream-share";
    fsType = "virtiofs";
    options = [
      # If you don't have this options attribute, it'll default to "defaults"
      # boot options for fstab. Search up fstab mount options you can use
      "defaults"
      "users" # Allows any user to mount and unmount
      "nofail" # Prevent system from failing if this drive doesn't mount

    ];
  };
}
