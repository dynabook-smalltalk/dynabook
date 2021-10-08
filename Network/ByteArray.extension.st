Extension { #name : #ByteArray }

{ #category : #'*Network-converting' }
ByteArray >> asSocketAddress [
	^SocketAddress fromOldByteAddress: self
]
