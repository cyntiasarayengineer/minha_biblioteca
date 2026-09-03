import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> scanTextFromCamera() async {
    // 1. Tira a foto
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return null;

    // 2. Prepara a imagem para o leitor do Google
    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    // 3. Reconhece o texto
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    // 4. Retorna o texto lido
    return recognizedText.text;
  }
}