{ ... }: {
  config = {
    # Prevent new users and groups being created
    users.mutableUsers = false;

    # Allow the user to log in as root without a password.
    # users.users.root.initialHashedPassword = lib.mkOverride 999 "";

    # Specify the hash of the root password.
    # > If set to an empty string (""), this user will be able to log in without being asked
    # > for a password (but not via remote services such as SSH, or indirectly via su or sudo).
    # users.users.root.hashedPassword  = null;

    # FIXME: Insecure. Enable hashed password as above.
    # This is specified for now for easier development over ssh
    users.users.root.password = "root";
  };
}