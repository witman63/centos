# Build image:

docker image build -t hub.rinis.cloud/library/centos7-default-template .

# Run container with:

docker container run -t -d hub.rinis.cloud/library/centos7-default-template

# Run container interactive:

docker container run -it hub.rinis.cloud/library/centos7-default-template bash

# Push image:

docker push hub.rinis.cloud/library/centos7-default-template


# Vars:

| Var:               | default:                | comments:
| ------------------ |:-----------------------:| -------------------------------------------:|
| EXAMPLE_VAR        | default-value           | voorbeeld van een te gebruiken variable     |

