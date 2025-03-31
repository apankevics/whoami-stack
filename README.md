# AWS
Repository used for Wandoo task:

![Image](https://github.com/user-attachments/assets/7d44e586-141e-46b3-9253-c0a497fa4104)

## Pre-Commit

Pre-commit is a useful tool for ensuring code quality and consistency in this repository, therefore it is mandatory.

To install pre-commit, follow these steps:

1. Make sure you have Python installed on your system. You can check by running `python --version` in your terminal.

2. Install pre-commit using pip by running the following command:
    ```
    pip install pre-commit
    ```

3. Once pre-commit is installed, navigate to the root directory of your repository and run the following command to set up the pre-commit hooks:
    ```
    pre-commit install
    ```
4. Then run following command to set up the pre-commit message checker.
    ```
    pre-commit install --hook-type commit-msg
    ```
If required to unistall pre-commit please run `pre-commit uninstall`.
