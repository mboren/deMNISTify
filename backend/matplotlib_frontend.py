""" Recognize digits drawn by user on a matplotlib plot

This script loads a model fit to MNIST data, then displays a blank
image in a matplotlib plot. You can draw on the plot with your mouse,
and erase it by pressing any key. As you draw, the title of the plot
will be updated with the digit recognized by the model.
"""
import matplotlib.pyplot as plt
import numpy as np
from keras.models import load_model
import interactiveplot as ip
import utilities

# plt.ion is required for this kind of interactivity
plt.ion()

fig = plt.figure()
ax = fig.add_subplot(111)

data = np.zeros((28,28))


# If I replace np.random.rand in ax.imshow with np.zeros or data, interactivity
# breaks. Initializing with random data and then immediately changing to zeros
# works fine though. I have *no idea* why this happens, and I'm definitely going
# come back to this and tinker with it in the future.
plot = ax.imshow(np.random.rand(28,28))
plot.set_data(data)

model = load_model('mnist_model.h5')


def recognition_func(image):
    return utilities.recognize_digit(model, image)

interactivePlot = ip.InteractiveMnistPlot(ax, plot, data, recognition_func)

# block=True is necessary for interactivity
plt.show(block=True)

