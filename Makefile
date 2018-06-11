file=../ENV_VARS
token=`cat $(file)`
export ATLAS_TOKEN = $(token)
# directory is the name of json-file
directory = $$(basename $$(pwd))

ifndef NO_CLOUD
FILE_NAME = $(directory)
else
FILE_NAME = $(directory)-no-cloud
endif


no-cloud:
	cat $(directory).json | jq 'del(."post-processors"[1])' > $(directory)-no-cloud.json

builds/virtualbox-ubuntu1804.box: virtualbox-ovf/box.ovf no-cloud
	#source ../ENV_VARS
	packer build -force $(FILE_NAME).json
	vagrant box remove --force file://builds/virtualbox-ubuntu1804.box || true

virtualbox-ovf/box.ovf:
	ansible-playbook check_box.yml

clean_all: rm_box rm_no_cloud
	rm virtualbox-ovf/*

rm_box:
	rm builds/virtualbox-ubuntu1804.box || true

rm_no_cloud:
	rm packer-ubuntu-de-devops-no-cloud.json || true

test:
	vagrant up --provider virtualbox
	inspec exec -t ssh://vagrant@$$(vagrant ssh-config | grep HostName | cut -d 'e' -f 2 | cut -d ' ' -f 2):$$(vagrant ssh-config | grep Port | cut -d 't' -f 2 | cut -d ' ' -f 2) -i $$(vagrant ssh-config | grep IdentityFile | cut -d ' ' -f 4) --password vagrant inspec_test/locale_de/

test_devsec:
	vagrant up
	inspec exec -t ssh://vagrant@$$(vagrant ssh-config | grep HostName | cut -d 'e' -f 2 | cut -d ' ' -f 2):$$(vagrant ssh-config | grep Port | cut -d 't' -f 2 | cut -d ' ' -f 2) -i $$(vagrant ssh-config | grep IdentityFile | cut -d ' ' -f 4) --password vagrant https://github.com/dev-sec/linux-baseline

test_newBox: vagrant_box_clean test

vagrant_box_clean:
	vagrant destroy --force || true
	vagrant box remove --force file://builds/virtualbox-ubuntu1804.box || true


all: rm_box builds/virtualbox-ubuntu1804.box vagrant_box_clean
