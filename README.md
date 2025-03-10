I personally got tired of writing cmake files, so I wrote more cmake files!

Basically, there is one function to care about: `build`

This function automates most things to do in cmake: creating targets, linking libraries, and even esoteric things like compile/linking options

Is it good? not really

Does it work? mostly

Does it "just work" for most c++ things? yes

Is this heavilly opinionated? absolutely, use my file structure or this wont work. I mean it. I am not going to change this (probably)

I make breaking changes from time to time, so just stick on whatever version you pick.

As long as you are not doing anything *too* out there, it should work