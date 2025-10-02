let
  azoller = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIukVfBl4xdLkVYoBsAfsrUQ7aG5qFiObDZbK8j6UGZj";
  users = [ azoller ];
in
{
  "romm_secret.age".publicKeys = users;
}