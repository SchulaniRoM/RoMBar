# RoMBar v.2.x
Runes of Magic - Addon

Vor über 10 Jahren begonnen und nie wirklich vollendet, habe ich das Projekt jetzt nach langjähriger Spielpause wieder aufleben lassen, da es weiterhin keine wirklich gute und vor allem fehlerfreien Alternativen gibt. Ziel ist es, eine möglichst umfangreiche Ansammlung von Vereinfachungen und Anpassungen für RoM zu erstellen, die modular und ressourceschonend arbeitet, ohne das ohnehin hohe Crit-Aufkommen des Spieles zu erhöhen.

features:
* extern konfigurierbare Info-Leiste für Runes of Magic
* vereint unzählige Tweaks und Features anderer Addons und macht diese somit unnötig (+Performance/+Speicher)
  * Anzeige oben oder unten
  * Originale UI ein-/ausblenden (und ggf. verschieben)
  * Tooltipskalierung für mehr Platz
  * Wahlweise Nutzung der Farbprofile von WoW
  * Aktionsleisten Tweaks - Cooldown / Entsperren mit SHIFT
  * feste Position für die Tooltips der Aktionsleisten-Buttons
  * Zählung/Speicherung/Statusanzeige eingegangener Mails
  * Automatische Reparatur beim Händler sofern nötig
  * Automatisches Auffüllen angelegter Wurfwaffen/Pfeile
  * Akustische Benachrichtigung bei Nachrichten (Gilde, Gruppe, Wisper)
  * Automatische Annahme von Gruppeneinladungen (Freunde, Gilde)
  * Automatische Annahme von Reiteinladungen (Freunde, Gilde)
  * Automatische Ablehnung von Duellanfragen
  * Syncronisierung der Freundeliste pro Server
  * Auf- und Absteigen auf Reittiere (zuletzt genutztes, Zufall, Reitgutscheinbenutzung)
  * Überspringen zahlreicher Bestätigungs-Dialoge (z.b. Sturobold, Gildenburg verlassen etc.)
  * Automatisches Abgeben erledigter Quests beim Anklicken des NPC
  * Automatisches Überspringen der Dialoge bei Händlern
  * zahlreiche Makros und Funktionen für verschiedene NPCs, Aufgaben und sesonale Events (siehe Doku)
* enthält eine überarbeitete Version von LootIt, welche um ein AutoSell-Feature erweitert wurde (original credits to Tinsus <tinsus@t-online.de>)
* enthält ext_cenedriliniframe, ext_characterframe, ext_craftframe, ext_housekeeperbuttons (credit to various unknown authors of these projects)
* modularer Aufbau ermöglicht komfortables Einbinden neuer Buttons und Module
* mehrsprachig (derzeit nur Deutsch - um Mitarbeit bei der Übersetzung wird gebeten)
* verzichtet auf übertrieben viele Eingriffe ins System, sondern reagiert vorzugsweise auf vorhandene events (+Stabilität)
* überarbeitetes Event-Handling (+Performance)

features in Arbeit:
  * Speicherung und Schnellzugriff auf Titel
  * Gruppenbutton zum Handling von Gruppen/Raids (neu einladen, speichern, diverse Automatiken)

geplante Features für die Zukunft:
  * Implementation von "TinyLittleRaidTool" (ein weiteres Addon von mir zum handling von raids)
  * Implementierung von ComOnIn und GroupInvite (inwiefern ich sie ersetze oder integriere ist noch nicht klar)
  * Implementation von AutoFollow und AutoQuest (ich gedenke, eine "stille" kommunikation zwischen gruppenmitgliedern zu implementieren)

Benötigte und empfohlene Addons:
* pyos - oder ähnliches Addon, welches das os-Object bereitstellt wird benötigt
* pylib, pyceh - der ClassExchangeHelper und die KeyBindings von Pyrrhus werden ausdrücklich empfohlen

Inkompatible und nicht mehr benötigte Addons:
* die im Ordner "advanced" vorhandenen Addons dürfen nicht doppelt vorhanden sein - also jeweils in advanced oder addons löschen
* jegliche Infobars wie z.b. XBar, BKInfoBar oder ZZInfoBar könnten Probleme bereiten. Da RoMBar diese Leisten ersetzt werde ich keinerlei Support dafür anbieten.
* TitleList und TitleSelect - die Funktionalitäten werden ab Version 2.2 komplett übernommen
* jegliche anderen Addons, deren Funktionalitäten übernommen wurden, sollten gelöscht werden z.B. (Liste unvollständig):
 * ActionBarCooldown
 * ActionBarTweaker
 * afStayWithMe
 * AmmoPersist
 * AutoAcceptInvitations
 * AutoEquipAmmo
 * AutoRepair
 * AutoSnoop
 * Gildenpieps
 * globalFriendList
 * GlobalCooldown
 * InvitedByFriend
 * ItemQueueSpeedup
 * MacroCooldowns
 * MountToggle
 * QuickTeleport
 * TimeStamp
 * Unlock_Actionbar_With_Shift
 * Vsell
 * WheresMyHome
 

Ich freue mich über Kritik, Anregungen, Wünsche und vor allem Bug- und Inkompatibilitätsmeldungen und biete gern Support und Hilfe an. Allerdings möchte ich auch darauf hinweisen, dass ich mich nicht um Addons kümmere, deren Funktionalität bereits implementiert ist, veraltet sind oder auch ohne RoMBar nicht fehlerfrei laufen. Viele andere Addons wurden zum Teil seit über 10 Jahren nicht mehr überarbeitet und die Lebenszeit, die ich dafür aufwenden müsste, investiere ich lieber in sinnvollere Aufgaben. Ebenso übernehme ich keinen Support für den Einsatz meiner Addons auf nicht-offiziellen RoM-Servern.


greetings
Schulani

ingame-contact: Schulani@Kerub oder Celesteria@Kerub
