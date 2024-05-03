Extension { #name : 'UUID' }

{ #category : '*SSW ReStore P3' }
UUID >> p3PrintUsing: delegate on: stream [
	"Print me on stream via double dispatch on delegate.
	Check the implementors of #p3PrintOn:using:"

	stream nextPutAll: self asString
]
