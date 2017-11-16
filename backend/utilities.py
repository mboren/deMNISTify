from skimage.transform import EuclideanTransform, warp
import numpy as np


def recognize_digit(model, image):
    """Preprocess image, pass to model, and return predicted digit"""
    input = np.array([np.reshape(center(image), (28,28,1))])
    result = model.predict(input, batch_size=1)
    digit = np.argmax(result[0])
    return digit


def center_of_mass(grid):
    """Find center of mass of an image."""

    x_center = 0
    y_center = 0
    total_weight = 0

    for y in range(grid.shape[0]):
        for x in range(grid.shape[1]):
            weight = grid[y,x]
            if weight > 0.0:
                x_center += grid[y,x] * x
                y_center += grid[y,x] * y
                total_weight += weight

    if total_weight > 0:
        return (y_center / total_weight, x_center / total_weight)
    else:
        return (grid.shape[0]/2, grid.shape[1]/2)


def center(image):
    """Shift image so its center of mass is right in the middle.

    This improves accuracy because the network was trained on centered data.
    """
    (rcm, ccm) = center_of_mass(image)
    (rc, cc) = (image.shape[0]/2, image.shape[1]/2)
    dr = (rc - rcm)
    dc = (cc - ccm)
    transf = EuclideanTransform(translation=(-dc,-dr))
    translated = warp(image, transf)
    return translated


