## Permissions

For the first boot, sddm needs access to the `.face.icon` to display it.
```
setfacl -m u:sddm:x ~/
setfacl -m u:sddm:r face/.face.icon
```

## Doc

[ArchWiki](https://wiki.archlinux.org/title/SDDM#User_icon_(avatar))