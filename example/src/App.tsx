/* eslint-disable react-native/no-inline-styles */
import * as React from 'react';
import { NativeModules } from 'react-native';

import { runOnJS } from 'react-native-reanimated';
import {
	StyleSheet,
	View,
	Text,
	LayoutChangeEvent,
	PixelRatio,
	TouchableOpacity,
	Alert,
	Clipboard,
} from 'react-native';
import { OCRFrame, scanOCR } from 'vision-camera-ocr';
import {
	useCameraDevices,
	useFrameProcessor,
	Camera,
} from 'react-native-vision-camera';

export default function App() {
	const [hasPermission, setHasPermission] = React.useState(false);
	const [ocr, setOcr] = React.useState<OCRFrame>();
	const [pixelRatio, setPixelRatio] = React.useState<number>(1);
	const devices = useCameraDevices();
	const device = devices.back;

	const frameProcessor = useFrameProcessor((frame) => {
		'worklet';
		const data = scanOCR(frame);
		// console.log(JSON.stringify(data, null, 2));
		runOnJS(setOcr)(data);
	}, []);

	React.useEffect(() => {

		try {
			NativeModules.TextDetector.imageToText("hello!");
		} catch (error) {
			console.log("failed to call imageToText", error);
		}

		(async () => {
			const status = await Camera.requestCameraPermission();
			setHasPermission(status === 'authorized');
		})();
	}, []);

	const renderOverlay = () => {
		return (
			<>
				{ocr?.result.blocks.map((block) => {
					return (
						<TouchableOpacity
							onPress={() => {
								Clipboard.setString(block.text);
								Alert.alert(`"${block.text}" copied to the clipboard`);
							}}
							style={{
								position: 'absolute',
								left: block.rect.x * pixelRatio,
								top: block.rect.y * pixelRatio,
								backgroundColor: 'white',
								padding: 8,
								borderRadius: 6,
							}}
						>
							<Text
								style={{
									fontSize: 25,
									justifyContent: 'center',
									textAlign: 'center',
								}}
							>
								{block.text}
							</Text>
						</TouchableOpacity>
					);
				})}
			</>
		);
	};

	return device !== undefined && hasPermission ? (
		<>
			<Camera
				style={[StyleSheet.absoluteFill]}
				frameProcessor={frameProcessor}
				device={device}
				isActive={true}
				frameProcessorFps={5}
				onLayout={(event: LayoutChangeEvent) => {
					setPixelRatio(
						event.nativeEvent.layout.width /
						PixelRatio.getPixelSizeForLayoutSize(
							event.nativeEvent.layout.width
						)
					);
				}}
			/>
			{renderOverlay()}
		</>
	) : (
		<View>
			<Text>No available cameras</Text>
		</View>
	);
}
