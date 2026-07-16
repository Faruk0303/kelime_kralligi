import 'dart:math';

enum MascotState {
  welcome,
  instruction,
  waiting,
  listening,
  correct,
  repeated,
  incorrect,
  notHeard,
  encouragement,
  levelCompleted,
}

class MascotDialogue {
  static final Random _random = Random();

  static String message({
    required MascotState state,
    String playerName = 'Arkadaşım',
    String? word,
    String? categoryName,
  }) {
    final safeName = playerName.trim().isEmpty
        ? 'Arkadaşım'
        : playerName.trim();

    final safeWord = word?.trim().toUpperCase() ?? '';

    final safeCategory = categoryName?.trim().isEmpty ?? true
        ? 'kelimeler'
        : categoryName!.trim();

    switch (state) {
      case MascotState.welcome:
        return _pick([
          'Merhaba $safeName! Ben Kral Leo. Yeni bir maceraya hazır mısın? 👋',
          'Hoş geldin $safeName! Seni gördüğüme çok sevindim! 🦁',
          'İşte benim kelime kahramanım! Hazırsan başlayalım $safeName! ✨',
        ]);

      case MascotState.instruction:
        return _pick([
          'Mikrofona dokun ve bir $safeCategory kelimesi söyle! 🎤',
          'Sıra sende! Mikrofona bas ve aklına gelen bir kelimeyi söyle.',
          'Haydi bakalım! Mikrofona dokun ve cevabını söyle.',
        ]);

      case MascotState.waiting:
        return _pick([
          'Ben hazırım! Sen hazır olduğunda mikrofona dokunabilirsin. 😊',
          'Acele etmene gerek yok. Cevabını düşün ve mikrofona dokun.',
          'İstersen sana küçük bir ipucu verebilirim! 💡',
        ]);

      case MascotState.listening:
        return _pick([
          'Seni dinliyorum... 👂',
          'Haydi söyle, kulaklarım sende! 🎤',
          'Sesini duymaya hazırım!',
        ]);

      case MascotState.correct:
        if (safeWord.isEmpty) {
          return _pick([
            'Harikasın! Doğru söyledin! 🌟',
            'Muhteşem! İşte bunu bekliyordum!',
            'Süpersin! Şimdi harfleri sıralayalım.',
          ]);
        }

        return _pick([
          'Aferin $safeName! $safeWord doğru bir kelime! 🌟',
          'Vay canına! $safeWord kelimesini harika söyledin!',
          'İşte bu! $safeWord doğru. Şimdi harfleri sıralayalım!',
          'Muhteşemsin! $safeWord kelimesini başarıyla buldun!',
        ]);

      case MascotState.repeated:
        if (safeWord.isEmpty) {
          return _pick([
            'Bu kelimeyi daha önce öğrenmiştik. Başka bir tane deneyelim!',
            'Bu kelime zaten tamamlandı. Yeni bir kelime bulabilir misin?',
            'Bunu biliyoruz! Şimdi farklı bir kelime söyleyelim.',
          ]);
        }

        return _pick([
          '$safeWord kelimesini daha önce öğrenmiştik. Başka bir tane deneyelim!',
          '$safeWord zaten tamamlandı. Yeni bir kelime bulabilir misin?',
          'Bu kelimeyi biliyoruz $safeName! Şimdi farklı bir kelime söyleyelim.',
        ]);

      case MascotState.incorrect:
        return _pick([
          'Çok güzel denedin! Bu kelime bu bölümde yok. Bir daha deneyelim.',
          'Sorun değil $safeName! Başka bir kelime söyleyebilirsin.',
          'Yaklaştın! Eminim bir sonraki denemende başaracaksın.',
          'Hatalar öğrenmenin bir parçasıdır. Haydi yeniden deneyelim!',
        ]);

      case MascotState.notHeard:
        return _pick([
          'Seni tam duyamadım. Biraz daha yüksek sesle konuşabilir misin? 👂',
          'Sesin bana ulaşmadı. Mikrofona biraz daha yakın konuşalım.',
          'Bir kez daha deneyelim. Bu kez kelimeyi biraz daha net söyle.',
        ]);

      case MascotState.encouragement:
        return _pick([
          'Harika gidiyorsun $safeName! Sakın vazgeçme!',
          'Sen gerçek bir Kelime Krallığı kahramanısın! 👑',
          'Her denemede biraz daha güçleniyorsun!',
          'Sana güveniyorum! Bunu başarabilirsin.',
        ]);

      case MascotState.levelCompleted:
        return _pick([
          'Başardın $safeName! Bu bölümün gerçek kahramanı sensin! 🎉',
          'Muhteşem! $safeCategory bölümü artık tamamlandı! 👑',
          'Vay canına! Yeni bir krallığın kapısını açtın!',
          'Seninle gurur duyuyorum $safeName! Yeni macera seni bekliyor!',
        ]);
    }
  }

  static String _pick(List<String> messages) {
    return messages[_random.nextInt(messages.length)];
  }

  const MascotDialogue._();
}
