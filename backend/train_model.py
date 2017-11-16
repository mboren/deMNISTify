"""
Train model on MNIST data and save to file
"""
import argparse
import keras
from keras.layers import Conv2D, Dense, Dropout, Flatten, MaxPooling2D
from keras.datasets import mnist
from keras.models import Sequential

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--modelfile', default='mnist_model.h5', type=str, help='Trained model will be written to this file')
    parser.add_argument('--epochs', default=5, type=int, help='# of epochs to train for')
    parser.add_argument('--batchsize', default=64, type=int, help='Batch size to use for each epoch')

    args = parser.parse_args()

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
              epochs=args.epochs,
              batch_size=args.batchsize,
              verbose=2,
              validation_data=(x_test,y_test) )

    model.save(args.modelfile)

    score, accuracy = model.evaluate(x_test,y_test)
    print('score', score)
    print('accuracy', accuracy)
