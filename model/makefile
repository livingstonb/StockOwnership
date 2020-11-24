
CFILES=model/*.c misc/*.c
OBJECTS=model/*.so misc/*.so
all:
	python setup.py build_ext --inplace --build-temp temp

clean:
	rm -f $(CFILES) $(OBJECTS)
	rm -rf temp
	rm -f output/*