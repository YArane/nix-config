# Java Dev Environment Template

## Setup

```bash
cd ~/projects/my-service
nix flake init -t ~/nix-config#java
echo ".direnv" >> .gitignore
direnv allow
```

## Switching JDK versions

Edit `flake.nix` and change the `jdk` line:

```nix
jdk = pkgs.jdk21;   # options: jdk8, jdk11, jdk17, jdk21
```

Then run `direnv reload` (or leave and re-enter the directory).

## How it works

- `direnv` detects `.envrc` when you `cd` into the project and activates the devShell
- `nix-direnv` caches the environment so subsequent activations are instant
- `JAVA_HOME` is set automatically
- `java`, `javac`, and `mvn` are available on `$PATH`

## Adding project-specific tools

Add packages to the `packages` list in `flake.nix`:

```nix
packages = [
  jdk
  pkgs.maven
  pkgs.gradle    # example
  pkgs.jq        # example
];
```
