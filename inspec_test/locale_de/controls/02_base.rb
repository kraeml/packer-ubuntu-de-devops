# encoding: utf-8
# copyright: 2017, The Authors

title 'OS Section'

packages = [
  "zsh",
  "vim",
  "git",
  "git-flow"
]

# you add controls here
control 'base-1.0' do
  impact 0.7
  title 'OS Family debian/ubuntu'
  describe os.family do
    it { should eq 'debian' }
  end
  describe os.name do
    it { should eq 'ubuntu' }
  end
  describe os.release do
     it { should eq '18.04' }
  end
  describe os.arch do
     it { should eq 'x86_64' }
  end
  packages.each do |package|
    describe package(package) do
      it { should be_installed }
    end
  end
end
