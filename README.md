# dotfiles

## Install Java

1. Sign-in ot Oracle site
2. Download the `.deb` binary
3. Double click to install it
4. Run the following commands

```
sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk-11*/bin/java 1081 
sudo update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk-11*/bin/javac 1081 
sudo update-alternatives --install /usr/bin/javadoc javadoc /usr/lib/jvm/jdk-11*/bin/javadoc 1081 
sudo update-alternatives --install /usr/bin/javap javap /usr/lib/jvm/jdk-11*/bin/javap 1081
```

5. Check the setup

```
java -version
```

## Install NodeJs

1. Download the `tar.xz` binary
2. Run the following commands

```
sudo mkdir -p /usr/lib/nodejs
sudo tar -xJvf node-v12.16.1-linux-x64.tar.xz -C /usr/lib/nodejs
sudo mv /usr/lib/nodejs/node-v12.16.1-linux-x64/ /usr/lib/nodejs/node-v12.16.1
sudo update-alternatives --install /usr/bin/node node /usr/lib/nodejs/node-v12.16.1/bin/node 1081
sudo update-alternatives --install /usr/bin/npm npm /usr/lib/nodejs/node-v12.16.1/bin/npm 1081
sudo update-alternatives --install /usr/bin/npx npx /usr/lib/nodejs/node-v12.16.1/bin/npx 1081
```

3. Check the setup

```
node --version
npm --version
npx --version
```
