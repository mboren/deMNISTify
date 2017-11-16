# deMNISTify

Train a classifier on MNIST, then draw numbers and see the output of the classifier
updated live as you draw.

[demo](http://s3.us-west-1.amazonaws.com/hi-mom-im-on-the-internet/mnist.html)

\<placeholder for cool gifs\>

Digit recognition is done with a Convolutional Neural Network implemented with Keras and Tensorflow.

There are two different ways you can run this thing:
1. a pure python program implementation that uses matplotlib for the UI
2. a web app that uses [Elm](http://elm-lang.org/) for the frontend and a Python websocket server for the backend

They have essentially equivalent functionality; the web version was written purely
because I like having a demo I can link to.

# Dependencies
- Python 3.6
- Python libraries:
    - matplotlib, scikit-image, numpy, keras, tensorflow
    - websockets (only required if you want to run the websocket server)
- Elm 0.18

# Matplotlib instructions
After using conda or pip to install: matplotlib, scikit-image, numpy, and keras:
```
$ cd backend
$ python train_model.py
```
After training finishes (which can take a while):
```
$ python matplotlib_frontend.py
```
Draw on the plot that comes up by dragging with your mouse, and press any key to erase.

# Web app instructions
```
$ cd frontend
$ elm-package install
$ elm-make src/App.elm --output=app.html
```
Open frontend/app.html in a web browser. If you draw on page that comes up,
you should see the question mark in the bottom left of the page turn into a
number. If it doesn't, it means that my server isn't running, which shouldn't
be surprising. You'll just have to run your own server:
```
cd ../backend
python train_model.py
python server.py
```

The server address is hardcoded in the Elm code due to \<insert weak excuses\>.

Find a line that looks something like this in `frontend/src/App.elm`:
```
      , digitRecognizer = Remote "ws://52.35.77.95:8765"
```
Change the string to "localhost:8765", run elm-make again, and refresh app.html.

# Browser compatibility
It should work in any modern browser, but I've only tried this in Google Chrome and Microsoft Edge.
It works fine in both, but Edge makes adjacent polygons in SVGs look prettier.
