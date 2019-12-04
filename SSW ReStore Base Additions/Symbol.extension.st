Extension { #name : #Symbol }

{ #category : #'*SSW ReStore Base Additions' }
Symbol >> sswInUnderscoreFormat [

	"Return a String which is the receiver in 'underscore format' (e.g. for SQL).
	e.g. the underscore form of the symbol #dateOfBirth would be 'date_of_birth'.

	NB - previously this method returned all-uppercase strings; it now returns all-lowercase"
	
	| readStream writeStream wasLowercase |
	
	readStream := ReadStream on: self.
	writeStream := WriteStream on: (String new: self size).
	wasLowercase := false.

	[readStream atEnd] whileFalse: 
		[| char |
		char := readStream next.
		(char isUppercase and: [wasLowercase])
			ifTrue: [writeStream nextPut: $_; nextPut: char asLowercase]
			ifFalse: [writeStream nextPut: char asLowercase].
		wasLowercase := char isLowercase].
			
	^writeStream contents
]
