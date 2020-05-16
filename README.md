# KofamScan
KofamScan is a gene function annotation tool based on KEGG Orthology and hidden Markov model.
You need [KOfam database](ftp://ftp.genome.jp/pub/db/kofam) to use this tool.
Online version is available on https://www.genome.jp/tools/kofamkoala/ .

## Requirements
- Linux
- Ruby >= 2.4
- HMMER >= 3.1
- GNU Parallel

## Usage
1. Download KOfam database from ftp://ftp.genome.jp/pub/db/kofam/ and decompress it. You will get profile HMMs in `profiles/` directory and `ko_list`.
2. Create `config.yml` in the same directory as `exec_annotation` script. See below for details.
3. Execute `exec_annotation`.

```console
$ ./exec_annotation -o result.txt query.fasta
```

## Query file
A query file is a FASTA file with one or more amino acid sequences. You cannot use nucleotide sequences.
Each sequence must have a unique name. A name of a sequence is a string between the header symbol (">") and the first blank character (whitespace, tab, line break, etc.). Do not put a whitespace right after ">".

## Profiles
Specify the path of the profile database you downloaded by giving `--profile` option to the command or writing it to `config.yml`. The path can be a directory, .hmm file, or .hal file.
If it is a directory, .hmm files in the directory will be used.
If a .hmm file, only the file will be used.
If a .hal file, files listed in the .hal file will be used. File paths in a .hal file are either absolute or relative to the directory of the file. Lines start with # are ignored.

KOfam has `prokaryote.hal` and `eukaryote.hal` in `profiles` directory. They are lists of profiles excluding eukaryote- and prokaryote-specific KOs respectively.
If you are interested in only several KOs, you can make your original .hal file and use it as a database. It will reduce computation time.

## Options
- `-o FILE`
  - The result are output to `FILE`. It defaults to `stdout`.
- `-p`, `--profile=PROFILE`
  - Use `PROFILE` as a profile database. See [Profiles](#profiles)
- `-k`, `--ko-list=FILE`
  - Use `FILE` as a KO list.
- `--cpu=N`
  - Set the number of `hmmsearch` processes started simultaneously to `N`. It defaults to 1 unless it is set in `config.yml`.
- `-c FILE`
  - Use `FILE` as a config file instead of `config.yml` in the same directory as `exec_annotation`.
- `--tmp-dir=DIR`
  - Use `DIR` as a temporary directory where hmmsearch results are. It will be created if not exist. It defaults to `./tmp`.
- `-E`, `--e-value=VALUE`
  - Require E-value to be smaller than or equal to `VALUE`. If not, an asterisk will not be added in `detail` format or the hit will not be reported in other formats.
- `-T`, `--threshold-scale=VALUE`
  - The score thresholds are multiplied by `VALUE`. For example, with `-T2` option, the thresholds become twice as strict.
- `-f`, `--format=FORMAT`
  - Set the format of the output to `FORMAT`. Three formats below are available.
  - `detail`
    - Default format. Gene name, assigned K number, threshold of the KO, hmmsearch score and E-value, and the definition of KO are shown. In addition, an asterisk '*' is added to the head of the line if the score is higher than the threshold.
  - `detail-tsv`
    - Tab separated values for `detail` format.
  - `mapper`
    - Format which can be used for [KEGG Mapper](https://www.genome.jp/kegg/mapper.html) input. It includes a gene name and an assigned K number separated by a tab. Here, an assigned K number represents a hit with score above the predefined threshold. Note that for some KOs, predefined score thresholds are not available when they are represented by a very few number of sequences in KEGG GENES.
  - `mapper-oneline`
    - Similar to `mapper`, but when more than one KO are assigned to a gene, all assigned KO are shown in one line separated by tabs.
- `--[no-]report-unannotated`
  - With `--report-unannotated` option, gene names are shown even when no KO is assigned (default when `--format=mapper(-oneline)`). With `--no-report-unannotated` such genes are not shown at all (default when `--format=detail`).
- `--create-alignment`
  - `hmmsearch`'s normal outputs per profile are stored in the temporary directory. In addition, domain information and alignments in the outputs will be rearranged per query.
  - Not compatible with `--reannotation`
- `-r`, `--reannotation`
  - Skip `hmmsearch` and assume that `hmmsearch` outputs are already in the temporary directory. This will help you to make an output in a different format or redo annotation changing thresholds.
  - Not compatible with `--create-alignment`
- `-h`, `--help`
  - Show brief help message.

## config.yml
The following variables can be set by `config.yml`.
- profile
  - Path to KOfam profiles.
  - `--profile` option takes precedence.
- ko_list
  - Path to the KO list of KOfam.
  - `--ko-list` option takes precedence.
- cpu
  - Number of `hmmsearch` processes started simultaneously.
  - `--cpu` option takes precedence.
- hmmsearch
  - Path to `hmmsearch` executable. If not given, it will be searched for PATH.
- parallel
  - Path to `parallel` executable. If not given, it will be searched for PATH.

## License
This software is released under the MIT License.
