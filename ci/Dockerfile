# For CI on a config git repo, all we need to do is combine
# the source code with coreos-assembler into an image to test.
FROM registry.svc.ci.openshift.org/coreos/cosa-buildroot:latest
WORKDIR /src
COPY . .
