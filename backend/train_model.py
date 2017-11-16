"""
Train model on MNIST data and save to file
"""
import keras
from keras.layers import Conv2D, Dense, Dropout, Flatten, MaxPooling2D
from keras.datasets import mnist
from keras.models import Sequential

file_name = 'mnist_model.h5'

# Data formatting

(x_train, y_train), (x_test, y_test) = mnist.load_data()

x_train = x_train.reshape(60000, 28, 28, 1)
x_train = x_train.astype('float32')

x_test = x_test.reshape(10000, 28, 28, 1)
x_test = x_test.astype('float32')

x_train /= 255
x_test /= 255

y_train = keras.utils.to_categorical(y_train, 10)
y_test = keras.utils.to_categorical(y_test, 10)

# Setup model architecture

model = Sequential()
model.add(Conv2D(32, (3, 3), activation='relu', input_shape=(28, 28, 1)))
model.add(Conv2D(64, (3,3), activation='relu'))
model.add(MaxPooling2D((2, 2), 2))
model.add(Dropout(0.25))
model.add(Flatten())
model.add(Dense(128, activation='relu'))
model.add(Dropout(0.5))
model.add(Dense(10, activation='softmax'))

model.compile(loss='categorical_crossentropy',
              optimizer=keras.optimizers.Adadelta(),
              metrics=['accuracy'])

model.fit(x_train,y_train,
          epochs=12,
          batch_size=128,
          verbose=2,
          validation_data=(x_test,y_test) )

model.save(file_name)

score, accuracy = model.evaluate(x_test,y_test)
print('score', score)
print('accuracy', accuracy)
