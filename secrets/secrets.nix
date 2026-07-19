let
  # primary keys
  oliver = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPFCbOpE20NLZKhFKY7qZWtVYQOARKs5v9nvP/ki98UI oliver@wildspitz";
  wildspitz = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIALBP8CCOaiAxm3kLV6faZe8U+L5CJxbGCfhKqCULu9M root@wildspitz";

  # backup keys
  bitwarden = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII8khycVK4Zr4PSCUHHYyc7il8QMu0U4520/i0nMWDWJ oliver@bitwarden.com";

  # keysets
  all = [
    oliver
    wildspitz
    bitwarden
  ];
in
{
  "grimmory.env.age" = {
    publicKeys = all;
    armor = true;
  };
}
