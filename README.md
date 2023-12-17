# Bulk Text From Images

I wanted a digital copy of Adolphe Thiers' 1881 _History of the French Revolution_. [Archive.org has a copy of volume II](https://archive.org/details/historyoffrench02thieuoft/page/n5/mode/2up), but their image recognition software generated an epub with only 12% confidence in its text recognition. Words were missing in the first page-turn. I was curious if Apple's [Vision text recognition](https://developer.apple.com/documentation/vision/recognizing_text_in_images) could do better. In some cases yes. The word "council-chamber", which did not appear in the Archive.org generated epub, does appear in Apple's output (see end of the first paragraph below). Regardless, it's interesting to have more control over how the output is created.

## Usage
In Xcode, edit the Run scheme and add two arguments passed on launch:
1. a path to directory of images containing text
2. the path of an output `.txt` file

Run the scheme, and your output file will be created with the text from the images.

## Known issues 
* The text formatter is not able to determine paragraph breaks properly. [Apple's API provides limited functionality](https://developer.apple.com/forums/thread/682495) and any formatting has to be written custom.
* Since it was built with a book in mind, it is hard coded to separate pages down the middle
* Multiple files are not being sorted in order. See TODO in `main.swift`.

## Example output
_note: markdown spacing was added by hand for this README, it is not part of the script output._

>HISTORY
>
>	02 ZItE
>
>	FRENCH REVOLUTION. CONCLUSION OF THE LEGISLATIVE ASSEMBLY.
>
>	THE Swiss had courageously defended the Tuileries, but their resistance had proved unavailing: the great staircase had been stormed and the palace taken. The people, thence- forward victorious, forced their way on all sides into this abode of royalty, to which they had always attached the notion of immense treasures, unbounded felicity, formidable powers, and dark projects. What an arrear of vengeance to be wreaked at once upon wealth, greatness, and power ! Eighty Swiss grenadiers, who had not had time to retreat, vigorously defended their lives, and were slaughtered with- out mercy. The mob then rushed into the apartments and fell upon those useless friends who had assembled to defend the King, and who, by the name of knights of the dagger, had incurred the highest degree of popular rancour. Their impotent weapons served only to exasperate the conquerors, aud to give greater probability to the plans imputed to the court. Every door that was found locked was broken open. Two ushers, resolving to defend the entrance to the great council-chamber and to sacrifice themselves to etiquette, VOL IL
>
>	B
>
>	2
>
>	HISTORY OF THE
>
>	were instantly butchered. The numerous attendants of the royal family fled tumultuously through the long galleries, threw themselves from the windows, or sought in the immense extent of the palace some obscure hiding-place wherein to save their lives. The Queen's ladies betook themselves to one of her apartments, and expected every moment to be attacked in their asylum. By direction of the Princess of Tarentum, the doors were unlocked, that the irritation might not be increased by resistance. The assailants made their appearance and seized one of them. The sword was already uplifted over her head. Spare the
>
>	women!" exclaimed a voice; 4 let us not dishonour the nation ! "
>
>	At these words the weapon dropped; the lives of the Queen's ladies were spared; they were protected and conducted out of the palace by the very men who were on the point of sacrificing them, and who, with all the popular fickleness, now escorted them and manifested the most ingenious zeal to save them.
>
>	After the work of slaughter followed that of devastation. The magnificent furniture was dashed in pieces, and the fragments scattered far and wide. The rabble penetrated into the private apartments of the queen and indulged in the most obscene mirth. They pried into the most secret recesses, ransacked every depository of papers, broke open every lock, and enjoyed the twofold gratification of curiosity and destruction. To the horrors of murder and pillage were added those of conflagration. The flames, having already consumed the sheds contiguous to the outer courts, began to spread to the edifice, and threatened that imposing abode of royalty with complete ruin. The desolation was not con- fined to the melancholy circuit of the palace; it extended to n distance. The streets were strewed with wrecks of furniture and dead bodies. Every one who fled, or was supposed to be fleeing, was treated as an enemy, pursued, and fired at. An almost incessant report of musketry sue- ceeded that of the cannon, and was every moment the signal of fresh murders. How many horrors are the attendants of victory, be the vanquished, the conquerors, and the cause for which they have fought, who and what they may! The executive power being abolished by the suspension of Louis XVI., only two other authorities were left in Paris, that of the Commune and that of the Assembly. As we have seen in the narrative of the 10th of August, deputies FRENCH REVOLUTION.
>
>	of the sections had assembled at the Hötel de Ville, expelled the former magistrates, seized the municipal power, and directed the insurrection during the whole night and day of %the 10th. They possessed the real power of action. They had all the ardour of vietory, and represented that new and impetuous revolutionary class, which had struggled during the whole session against the inertness of the other more enlightened but less active class of men, of which the Legis- lative Assembly was composed.
>
>	The first thing the deputies of the sections did was to displace all the high authorities, which, being closer to the supreme power, were more attached to it. They had
>
>	suspended the staff of the national guard, and, by with- drawing Mandat from the palace, had disorganised its defence. Santerre had been invested by them with the command of the national guard. They had been in not less haste to suspend the administration of the department, which, from the lofty region wherein it was placed, had continually curbed the popular passions, in which it took 11O share.
>
>	As for the municipality, they had suppressed the general council, substituted themselves in the place of its authority, and merely retained Petion, the mayor, Manuel, the pro- cureur syndie, and the sixteen municipal administrators. All this had taken place during the attack on the palace. Danton had audaciously directed that stormy sitting; and when the grape-shot of the Swiss had caused the mob to fall back along the quays, he had gone out saying, " Our brethren call for aid; let us go and give it to them." His
>
>	presence had contributed to lead the populace back to the field of battle, and to decide the victory. When the combat was over, it was proposed that Petion should be released from the guard placed over him and rein- stated in his office of mayor. Nevertheless, either from real anxiety for his safety, or from fear of giving themselves too scrupulous a chief during the first moments of the insur- rection, it had been decided that he should be guarded a day or two longer, under pretext of putting his life out of danger. At the same time, they had removed the busts of Louis XVI., Bailly, and Lafayette, from the hall of the general council. The new class which was raising itself thus displaced the first emblems of the Revolution, in order to substitute its own in their stead.
>
>	B 2
