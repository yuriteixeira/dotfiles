cd "$(dirname "$0")"

./misc/packages/01-preflight.sh
./misc/packages/02-base.sh
./misc/packages/desktop/01-foundations.sh
./misc/packages/desktop/02-sway.sh
./misc/packages/desktop/03-file-management.sh
./misc/packages/desktop/04-printer.sh
./misc/packages/desktop/05-productivity.sh
