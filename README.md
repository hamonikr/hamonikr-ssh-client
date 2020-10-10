# SSH Client for HamoniKR

SSH Client for HamoniKR 4.0

upstream : [https://github.com/asbru-cm/asbru-cm](https://github.com/asbru-cm/asbru-cm)


[![Travis][travis-badge]][travis-url]
[![License][license-badge]][license-url]
[![RPM Packages][rpm-badge]][rpm-url]
[![Debian Packages][deb-badge]][deb-url]

### Features

- Simple GUI to manage/launch connections to remote machines
- Scripting possibilities, 'ala' SecureCRT
- Configurable pre or post connection local commands execution
- Configurable list of macros (commands) to execute locally when connected or to send to connected client
- Configurable list of conditional executions on connected machine via 'Expect':
  - forget about SSH certificates
  - chain multiple SSH connections
  - automate tunnels creation
  - with line-send delay capabilities
- [KeePassX](https://www.keepassx.org/) integration
- Ability to connect to machines through a Proxy server
- Cluster connections
- Tabbed/Windowed terminals
- Wake On LAN capabilities
- Local and global variables, eg.: write down a password once, use it ANY where, centralizing its modification for faster changes! use them for:
  - password vault
  - reusing connection strings
- Seamless Gnome/Gtk integration
- Tray icon for 'right button' quick launching of managed connections. Screenshots and statistics.
- DEB, RPM and .TAR.GZ packages available

### Installation

- HamoniKR / Debian / Ubuntu

  ````
  curl -sL https://apt.hamonikr.org/setup_hamonikr.jin | sudo -E bash -

  sudo apt install asbru-cm
  ````


### License

This project is licensed under the GNU General Public License version 3 <http://www.gnu.org/licenses/gpl-3.0.html>.  A full copy of the license can be found in the [LICENSE](./LICENSE) file.

### Packages

The repositories for our RPM and DEB builds are thankfully sponsored by [packagecloud](https://packagecloud.io/). A great thanks to them.

<a title="Private Maven, RPM, DEB, PyPi and RubyGem Repository" href="https://packagecloud.io/"><img height="46" width="158" alt="Private Maven, RPM, DEB, PyPi and RubyGem Repository" src="https://packagecloud.io/images/packagecloud-badge.png" /></a>


[travis-badge]: https://travis-ci.org/asbru-cm/asbru-cm.svg?branch=master
[travis-url]: https://travis-ci.org/asbru-cm/asbru-cm
[license-badge]: https://img.shields.io/badge/License-GPL--3-blue.svg?style=flat
[license-url]: LICENSE
[deb-badge]: https://img.shields.io/badge/Packages-Debian-blue.svg?style=flat
[deb-url]: https://packagecloud.io/asbru-cm/asbru-cm?filter=debs
[rpm-badge]: https://img.shields.io/badge/Packages-RPM-blue.svg?style=flat
[rpm-url]: https://packagecloud.io/asbru-cm/asbru-cm?filter=rpms
[liberapay-badge]: http://img.shields.io/liberapay/patrons/asbru-cm.svg?logo=liberapay
[liberapay-url]: https://liberapay.com/asbru-cm/donate
