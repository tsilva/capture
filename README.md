# capture

Keeping ideas, tasks, and other thoughts in your head is not a good idea as they will run a loop and constantly ping for your attention. Personally, I dump every worthwhile thought that comes into my mind directly into Gmail for later review (borrowing from the GTD - Getting Things Done process).

## How to install

### Clone and install

* Install Python (eg: Python 3.9 from Windows Store)
* Clone this repo
* Run "pip install"
* Add repo to your Windows 10 path

### Fetch Gmail API client_secret.json

* Create project in Google Cloud Platform
* Add Gmail API to project
* Click projects Credentials tab
* Add Oauth 2.0 Client ID
* Click download button next to created id
* Copy file to "capture" repo folder and name it "client_secret.json"