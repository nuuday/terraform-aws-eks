.PHONY: check-docs check-fmt check-all docs

check-all: check-docs check-fmt

check-docs:
	pre-commit run --show-diff-on-failure --all-files terraform_docs

check-fmt:
	pre-commit run --all-files terraform_fmt
