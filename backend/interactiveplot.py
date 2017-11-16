"""Encapsulates interactive plots used for playing with MNIST

This enables several forms of interactivity:
1. You can draw on the plot with your mouse.
2. Pressing any key will erase the plot.
3. The plot title will be automatically updated with the currently
   recognized digit as you draw.
"""
import numpy as np
from utilities import recognize_digit


class InteractiveMnistPlot:
    def __init__(self, ax, plot, data, digit_model):
        self.drawing = False
        self.ax = ax
        self.plot = plot
        self.data = data
        self.digit_model = digit_model
        self.ax.set_title('?')

        # These properties are never used directly, they're only stored to prevent them
        # from getting garbage collected
        self.cid_motion = self.plot.figure.canvas.mpl_connect('motion_notify_event', self.on_mouse_move)
        self.cid_mouse_down = self.plot.figure.canvas.mpl_connect('button_press_event', self.on_mouse_down)
        self.cid_mouse_up = self.plot.figure.canvas.mpl_connect('button_release_event', self.on_mouse_up)
        self.cid_key_up = self.plot.figure.canvas.mpl_connect('key_release_event', self.on_key_up)

    def on_mouse_down(self, event):
        self.drawing = True

    def on_mouse_up(self, event):
        self.drawing = False

    def on_key_up(self, event):
        """Erase drawn image after any key is pressed"""
        self.data = np.zeros_like(self.data)
        self.plot.set_data(self.data)
        self.ax.set_title('?')

        self.plot.figure.canvas.draw()

    def on_mouse_move(self, event):
        if self.drawing:
            if event.xdata is not None and event.ydata is not None:
                # Mouse event coordinates have integer values in the center of image
                # pixels, whereas image coordinates have integer values at pixel corners,
                # so we need to shift the coordinates, floor them, and then clamp
                # inside image bounds.
                x = min(self.data.shape[1]-1, max(0, int(event.xdata + 0.5)))
                y = min(self.data.shape[0]-1, max(0, int(event.ydata + 0.5)))

                self.data[y, x] = 1

                # Add 0.5 to neighboring pixels. The lighter edges improve recognition
                # accuracy because it makes the drawn images more similar to original
                # MNIST data. I suspect that this would not be necessary with a
                # convolutional neural network.
                for dy in [-1, 0, 1]:
                    yn = y + dy
                    for dx in [-1, 0, 1]:
                        xn = x + dx
                        if 0 < yn < self.data.shape[0] and 0 < xn < self.data.shape[1]:
                            self.data[yn, xn] = min(1, self.data[yn, xn] + 0.5)

                # Set plot title to prediction
                recognized_digit = recognize_digit(self.digit_model, self.data)
                self.ax.set_title(str(recognized_digit))

                self.plot.set_data(self.data)
                self.plot.figure.canvas.draw()

