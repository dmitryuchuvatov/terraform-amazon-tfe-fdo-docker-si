#

## Pre-requirements
- Install Graphviz
```
brew install graphviz
```
- Install Python 3
```
brew install python3
```

## Install Diagrams
```
pip3 install diagrams
```

# Build diagrams

## Sample

- Create a new file called **diagram.py**
```
# diagram.py
from diagrams import Diagram
from diagrams.aws.compute import EC2
from diagrams.aws.database import RDS
from diagrams.aws.network import ELB

with Diagram("Web Service", show=False):
    ELB("lb") >> EC2("web") >> RDS("userdb")
```
- Run the following command
```
python3 diagram.py
```

- Check the output `web_service.png`

![web_service](https://github.com/dmitryuchuvatov/fdo-es-docker/assets/119931089/8cf8fdd4-77a2-43fe-ab42-3fb97938bf05)
  
