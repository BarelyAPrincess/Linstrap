#!/bin/bash

is_function "yes" || error "'yes' is not a function."
is_function "no" || error "'no' is not a function."