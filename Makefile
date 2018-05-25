file=../ENV_VARS
token=`cat $(file)`
export ATLAS_TOKEN = $(token)
directory = $$(basename $$(pwd))
builds/virtualbox-ubuntu1804.box: virtualbox-ovf/box.ovf
	#source ../ENV_VARS
	packer build -force $(directory).json
	vagrant box remove --force file://builds/virtualbox-ubuntu1804.box || true

virtualbox-ovf/box.ovf:
	ansible-playbook check_box.yml

clean_all: rm_box
	rm virtualbox-ovf/*

rm_box:
	rm builds/virtualbox-ubuntu1804.box || true

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
