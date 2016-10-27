import QtQuick 2.0

Item {
	id: root
	width: 200
	height: implicitHeight

	property int seed: Math.random()*1700 + 1

	//http://xkcd.com/1750/

	Image {
		id: img
		anchors.fill: parent
		asynchronous: true
		fillMode: Image.PreserveAspectCrop
		onSourceSizeChanged: {
			root.implicitHeight = paintedHeight*root.width/paintedWidth
		}
	}

	Component.onCompleted: {
		console.log("http://xkcd.com/%1/".arg(root.seed))
		var xhr = new XMLHttpRequest();
		xhr.onreadystatechange = function() {
			if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
				var t = xhr.responseText
				var p = t.search("<div id=\"comic\">")
				t = t.slice(p)
				p = t.search("src=")
				t = t.slice(p+5)
				p = t.search('"')
				t = t.slice(0, p)
				img.source = "http:"+t
			}
		}

		xhr.open("GET", "http://xkcd.com/%1/".arg(root.seed))
		xhr.send()
	}
}
