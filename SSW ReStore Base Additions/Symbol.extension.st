Extension { #name : #Symbol }

{ #category : #'*SSW ReStore Base Additions' }
Symbol >> sswInUnderscoreFormat [

	"Return a String which is the receiver in 'underscore format' (e.g. for SQL).
	e.g. the underscore form of the symbol #dateOfBirth would be 'date_of_birth'.

	NB - previously this method returned all-uppercase strings; it now returns all-lowercase"

	| writeStream last |

	"Leave some room for underscores to avoid growing the stream.
	We'll make a copy in #contents regardless, so overshooting isn't a problem."
	writeStream := String writeStream: self size + 3.
	last := self first.
	self do: 
		[ :char |
		(char isUppercase and: [last isUppercase not]) ifTrue: [writeStream nextPut: $_].
		writeStream nextPut: char asLowercase.
		last := char].
	^writeStream contents
]
