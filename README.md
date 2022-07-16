# HDR Camera

The HDR effect is made by taking multiple photos at different exposures. This app takes 4 photos. We start with the darkest photo, and gradually add the brighter photos. We want to avoid the over exposed areas in the brighter photos, so we invert the photo and blur it to create a mask. We then multiply the photo with the mask and add it to the darker photos. You can see the full function [here](https://github.com/heestand-xyz/HDR-Camera/blob/398f8c710c4666935bc47932ebd3edc981e026e7/Sources/View%20Models/HDR%20Effect/HDREffect.swift#L33).


