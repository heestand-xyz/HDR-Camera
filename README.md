<img src="https://github.com/heestand-xyz/HDR-Camera/blob/main/Assets/HDR%20Camera%20-%20App%20Icon.png?raw=true" width="128"/>

# HDR Camera iOS App

<img src="https://github.com/heestand-xyz/HDR-Camera/blob/main/Assets/HDR%20Camera%20-%20Screen%201.png?raw=true" width="200"> <img src="https://github.com/heestand-xyz/HDR-Camera/blob/main/Assets/HDR%20Camera%20-%20Screen%202.png?raw=true" width="200"> <img src="https://github.com/heestand-xyz/HDR-Camera/blob/main/Assets/HDR%20Camera%20-%20Screen%203.png?raw=true" width="200"> <img src="https://github.com/heestand-xyz/HDR-Camera/blob/main/Assets/HDR%20Camera%20-%20Screen%204.png?raw=true" width="200">

[HDR Camera on AppStore](https://apps.apple.com/us/app/hdr-effect-camera/id1580227677)

The HDR effect is made by taking multiple photos at different exposures. This app takes 4 photos. We start with the darkest photo, and gradually add the brighter photos. We want to avoid the over exposed areas in the brighter photos, so we invert the photo and blur it to create a mask. We then multiply the photo with the mask and add it to the darker photos. You can see the full function [here](https://github.com/heestand-xyz/HDR-Camera/blob/398f8c710c4666935bc47932ebd3edc981e026e7/Sources/View%20Models/HDR%20Effect/HDREffect.swift#L33).


