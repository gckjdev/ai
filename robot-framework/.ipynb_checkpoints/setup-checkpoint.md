## Install package
```bash
pip3 install robotframework
pip3 install --upgrade robotframework-seleniumlibrary
pip3 install --upgrade robotframework-requests
```

## Create first sample test case file
```bash
mkdir -p ~/robot-tests/testcases
cd ~/robot-tests
```
```python
*** Test Cases ***
Example Test Case
    Log    Hello, Robot Framework!
```

## Run the test case
```bash
cd ~/robot-tests/testcases
robot example.robot
```