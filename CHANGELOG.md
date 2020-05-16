# Change Log
## v1.3.0
- `detail-tsv` format is added.

## v1.2.0
- Temporary files in `tabular` directory are now concatenated into one file in order not to run out i-nodes. Use `--keep-tabular` option to prevent files from being contatenated.
- When running the command with `--create-alignment`, temporary files in `output` directory are concatenated as well. `--keep-output` option disables this behavior.

## v1.1.0
- `-E` and `-T` options are added.

## v1.0.0
- Initial release
