Hellgrave Exodus TFS 1.4.2
===============

The Hellgrave Exodus Server is a donated MMORPG server emulator written in C++. It is a fork of the The Forgotten Server 1.4.2 Branch, using Real Map custom, created by us and highly modified with custom content.<br>

Hellgrave Exodus Server is a TFS 1.4.2 Real Map full customised to enhanced the experience of players.
It contains a lot of systems and modules.

### Getting Started

To compile server and client first download the new vcpkg and vcpkg_installed
* Download it via the forum Exodus Github Category (VCPKG + VCPKG Installed)

Place vcpkg_installed folder inside vc17 folder.<br>
Place vcpkg folder in one of your hard drive C:, D:...<br>
Open system variables (search windows: variables) options, two blocks will appear, on the second one, find "VCPKG_ROOT"<br>
if doesn't exist, create a new variable on the second one called "VCPKG_ROOT" then set the path of vcpkg downloaded.<br>
<br>
Open CMD (comand prompt), write: `C:` or letter of your hard drive where vcpkg is copied.<br>
write: `cd vcpkg` then `vcpkg integrate install`<br>
Open vc17 folder right click on exodus_client.sln and open it with visual studio 2026 (visual studio).<br>

Required: Visual Studio 2026, C++ development, english lenguage.
Windows SDK 10(10.0.19041.0)
MSVC v143 - VS 2022 C++ x64/x86
Windows SDK 11(10.0.22000.0)

On the Visual Studio home screen, in the Visual Studio installer product click the Install button.<br>
On the next screen, select:<br>
Desktop Development with C++ and Mobile Development for Android.<br>
Then in Language Packs, select:<br>
English.<br>
Continue the installation and click in the Install button.<br>
Install Git.<br>

### Compiling Android

To compile on android you need to create C:\android folder and put inside the content of android_libs inside<br>

* Download it via the forum Exodus Github Category (Android Libs)

Also install Mobile development with C++ using Visual Studio Installer

Then open android/otclientv8.sln, open Tools -> Options -> Cross Platform -> C++ -> Android and:

Set Android SDK to C:\android\android-sdk\build-tools_r30<br>
Set Android NDK to C:\android\android-sdk\android-ndk-r23c<br>
Set Java SE to: C:\android\android-sdk\jdk8u302-b08<br>
Set Apache Ant to C:\android\android-sdk\apache-ant-1.9.7<br>

Possible error on Android ( Fonts ) opening on android 15, fonts can get a problem (someone reported), try download any otcv8 and delete fonts and copy the new one and try again.

Open powershell and go to Path of client: (cd clientPath):<br>
Run: `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` This will allow to execute the script create_android_assets.ps1 that compiles (init.lua, data, mods, modules and layout into a single data.zip directly inside assets folder on otclientv8 folder)<br>
Run: `.\create_android_assets.ps1`<br>
If for any reason doesnt work Run: `powershell -ExecutionPolicy Bypass -File .\create_android_assets.ps1`<br>
Select Release and ARM64<br>
Build otclientv8 (the one with phone icon, not folder, at right on visual studio 2022 see otclientv8 right click and generate)<br>
Compilation has by default some warnings (default otcv8 also has this warnings) but compilation works and client has no errors.

### Support

If you need help, please visit the [support forum on OpenGamesCommunity](https://opengamescommunity.com/index.php). Our issue tracker is not a support forum, and using it as one will result in your issue being closed.

### Issues

We use the [issue tracker on GitHub](https://github.com/Open-Games-Community/Exodus_online/issues). Keep in mind that everyone who is watching the repository gets notified by e-mail when there is activity, so be thoughtful and avoid writing comments that aren't meaningful for an issue (e.g. "+1"). If you'd like for an issue to be fixed faster, you should either fix it yourself and submit a pull request, or place a bounty on the issue.
