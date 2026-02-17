# Arguments and Flags

## Patterns

- Use `getopts` for short flags.
- For long flags, parse manually with a `while [ $# -gt 0 ]` loop.
- Provide a `usage()` function and `-h/--help` support.

## Example

```bash
usage() {
  printf "Usage: %s [-f file] [-v]\n" "$0"
}

while [ $# -gt 0 ]; do
  case "$1" in
    -f) file="$2"; shift 2;;
    -v) verbose=1; shift;;
    -h|--help) usage; exit 0;;
    --) shift; break;;
    *) printf "Unknown arg: %s\n" "$1"; usage; exit 2;;
  esac
done
```
