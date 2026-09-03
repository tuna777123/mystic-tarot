import 'minor_arcana_semantics_es.dart';
import 'minor_arcana_semantics_fr.dart';
import 'minor_arcana_semantics_pt.dart';
import 'minor_arcana_semantics_tr.dart';

/// Returns card-specific Minor Arcana guidance as
/// [upright meaning, reversed/shadow meaning, grounded action].
///
/// The data is intentionally authored per card rather than assembled from a
/// generic rank + suit template, so each of the 56 Minor Arcana carries a
/// distinct reflective signal in every launch language.
List<String>? minorArcanaSemantic(String cardName, String languageCode) {
  return switch (languageCode) {
    'EN' => minorArcanaSemanticsEnglish[cardName],
    'TR' => minorArcanaSemanticsTurkish[cardName],
    'ES' => minorArcanaSemanticsSpanish[cardName],
    'FR' => minorArcanaSemanticsFrench[cardName],
    'PT-BR' => minorArcanaSemanticsPortugueseBrazil[cardName],
    _ => null,
  };
}

const minorArcanaSemanticsEnglish = <String, List<String>>{
  'Ace of Wands': [
    'A fresh spark wants expression now; the value is not certainty but the courage to give one alive idea a real beginning.',
    'Excitement may be burning without direction, or fear of a false start may be keeping a genuine impulse permanently theoretical.',
    'Choose the idea with the most energy and give it one small, visible start today.',
  ],
  'Two of Wands': [
    'You can see beyond your current boundary, and the real work is choosing which possibility deserves a deliberate plan rather than more imagining.',
    'Planning may have become a safe substitute for movement, especially if expansion would require leaving a familiar identity or environment.',
    'Name the next horizon you actually want and take one low-risk step toward testing it.',
  ],
  'Three of Wands': [
    'Early effort is beginning to create reach, making this a useful moment to notice what has traction and coordinate the next stage of expansion.',
    'You may be waiting for outside confirmation while neglecting follow-through, timing, or the partnerships needed to carry momentum farther.',
    'Review what is already moving and strengthen the one channel most likely to extend it.',
  ],
  'Four of Wands': [
    'A real milestone deserves recognition, especially where belonging, home, teamwork, or shared effort has created a stable place to stand.',
    'Celebration can become performance when the foundation underneath it feels unstable, exclusive, or dependent on everyone pretending things are fine.',
    'Mark the progress honestly and invest in the people or structures that make the stability real.',
  ],
  'Five of Wands': [
    'Different agendas are colliding, but the friction can sharpen skill and reveal what matters if the disagreement stays purposeful rather than personal.',
    'Competition may be consuming more energy than the goal itself, turning useful difference into noise, comparison, or a fight for status.',
    'Identify the one disagreement worth solving and set a fair rule for how it will be handled.',
  ],
  'Six of Wands': [
    'Recognition reflects effort that has become visible; receive the credit without shrinking and use it as evidence of what your preparation can do.',
    'Approval may be becoming the measure of your worth, making image, applause, or proving yourself more important than the work beneath them.',
    'Accept what you earned, then define the next standard privately before chasing another reaction.',
  ],
  'Seven of Wands': [
    'Something worth protecting is asking for a clear boundary, and conviction matters more than pleasing every person who questions your position.',
    'Constant defense can create a siege mentality in which every challenge feels like a threat and exhaustion is mistaken for commitment.',
    'Protect one true non-negotiable and deliberately release one battle that does not deserve your energy.',
  ],
  'Eight of Wands': [
    'Movement is accelerating and scattered pieces can align quickly when communication, timing, and intention are kept simple and direct.',
    'Speed may be creating crossed messages, impulsive commitments, or motion for its own sake before everyone understands what is actually happening.',
    'Remove one unnecessary delay and send the clearest message needed to keep the right thing moving.',
  ],
  'Nine of Wands': [
    'You have learned enough from earlier strain to protect your energy and continue, but persistence now needs boundaries as much as toughness.',
    'Past difficulty may be making you anticipate another attack, so vigilance is consuming the strength you still need to finish or recover.',
    'Keep the boundary that protects the finish line and schedule recovery as part of the plan, not after it.',
  ],
  'Ten of Wands': [
    'Responsibility has accumulated into a heavy load, revealing both what you can carry and what no longer needs to remain yours alone.',
    'Overload may have become proof of usefulness or control, making delegation feel unsafe even while the burden reduces the quality of everything.',
    'Drop, delegate, or renegotiate one concrete responsibility before accepting another.',
  ],
  'Page of Wands': [
    'Curiosity is asking for an experiment, not a finished identity; a small creative risk can teach more than prolonged speculation about potential.',
    'Novelty may be replacing commitment, leaving a trail of exciting beginnings that never receive enough attention to become meaningful.',
    'Turn the most interesting idea into a tiny test with a clear start and finish.',
  ],
  'Knight of Wands': [
    'Bold energy is available for a decisive push, especially when adventure is serving a chosen direction rather than simply escaping stillness.',
    'Impulse, impatience, or attraction to the next exciting thing may be outrunning consequences and leaving unfinished commitments behind.',
    'Channel the speed into one bounded sprint and decide what must be completed before you pivot again.',
  ],
  'Queen of Wands': [
    'Warm confidence and creative self-trust let you take up space without taking it from anyone else, making encouragement and leadership feel natural.',
    'Comparison or the need to appear magnetic may be turning confidence into performance and quietly disconnecting you from your own needs.',
    'Act from what genuinely energizes you and offer encouragement without making yourself smaller.',
  ],
  'King of Wands': [
    'A wider vision can become useful leadership when direction is clear and other people are trusted to bring their own intelligence to execution.',
    'Impatience or certainty in your own vision may be becoming domination, especially if speed matters more than listening or sustainable ownership.',
    'Set the direction clearly, define the standard, and leave meaningful ownership with the people doing the work.',
  ],

  'Ace of Cups': [
    'An emotional opening is available: a feeling, connection, creative current, or capacity to receive can deepen when it is welcomed without forcing an outcome.',
    'Emotion may be blocked, idealized, or overflowing faster than you can understand it, making intensity feel more trustworthy than reality.',
    'Name what you genuinely feel and make room to receive without demanding that the feeling decide everything.',
  ],
  'Two of Cups': [
    'Mutual recognition is possible when both sides are present as equals and connection is built through clear exchange rather than projection.',
    'Attraction or closeness may be hiding an imbalance in effort, expectation, or consent, leaving one person to carry the meaning for both.',
    'Ask what each person is actually offering and look for reciprocity in behavior, not only chemistry.',
  ],
  'Three of Cups': [
    'Friendship, celebration, and shared emotional support can restore perspective by reminding you that joy grows when it has trustworthy witnesses.',
    'Social energy may be tipping into excess, gossip, comparison, or belonging that requires you to perform a version of yourself.',
    'Reach toward the people with whom celebration and honesty can exist at the same time.',
  ],
  'Four of Cups': [
    'Dissatisfaction deserves attention because it may be showing that an old source of meaning no longer reaches you, while another option remains overlooked.',
    'Emotional numbness or habitual refusal may be making every offer look empty before you have examined what you actually need.',
    'Name what feels missing, then inspect one option you have been dismissing automatically.',
  ],
  'Five of Cups': [
    'Loss is real and should not be rushed past, yet grief can coexist with resources, relationships, and possibilities that have not disappeared.',
    'Pain may be narrowing your field of view until the loss becomes the whole story and available support feels irrelevant or undeserved.',
    'Honor exactly what was lost, then name one person, value, or possibility that still remains.',
  ],
  'Six of Cups': [
    'Memory can reconnect you with tenderness, generosity, and parts of yourself that existed before current pressures became so loud.',
    'Nostalgia may be editing the past, tempting you to return to a dynamic whose familiarity is being confused with present-day health.',
    'Recover one quality worth keeping from the past without recreating the entire old pattern.',
  ],
  'Seven of Cups': [
    'Many possibilities are competing for emotional attention, making discernment more valuable than adding another fantasy to the list.',
    'Wishful thinking, escapism, or fear of choosing may be keeping every option alive so none of them has to meet reality.',
    'Reduce the field using evidence and values, then test one option in the real world.',
  ],
  'Eight of Cups': [
    'Something may no longer nourish you enough to justify continued emotional investment, and leaving can be an act of honesty rather than failure.',
    'Fear of departure may keep you circling an empty situation, while avoidance can also disguise itself as spiritual growth or independence.',
    'Name what is no longer being fed and identify the next concrete threshold you would cross if you chose to leave.',
  ],
  'Nine of Cups': [
    'Satisfaction is available when you let yourself recognize what is already working instead of postponing pleasure until every condition is perfect.',
    'Comfort can slide into excess, self-congratulation, or dependence on getting what you want as proof that you are safe or worthy.',
    'Enjoy one genuine success fully, then ask whether the desire still aligns with the life you want to build.',
  ],
  'Ten of Cups': [
    'Belonging and emotional fulfillment become durable when shared values are lived in ordinary behavior rather than reserved for ideal moments.',
    'The image of harmony may be pressuring people to suppress conflict, difference, or needs that do not fit the preferred family or relationship story.',
    'Define what belonging looks like in repeated behavior and make room for one honest difference inside it.',
  ],
  'Page of Cups': [
    'Sensitivity and imagination are bringing a fresh emotional message that deserves curiosity before it is judged as childish, impractical, or too vulnerable.',
    'You may be reading too much into a feeling or signal, or using innocence to avoid the responsibility of speaking clearly.',
    'Express the feeling in plain language and let the response give you information instead of inventing the ending.',
  ],
  'Knight of Cups': [
    'Idealism can become a sincere offer when feeling is translated into respectful action and the other person is allowed to remain real, not symbolic.',
    'Fantasy, rescue dynamics, or the thrill of pursuit may be more compelling than the ordinary truth of the person or goal being pursued.',
    'Make one honest offer without scripting the response, then notice what reality gives back.',
  ],
  'Queen of Cups': [
    'Deep empathy and emotional intelligence can hold complexity without immediately fixing it, especially when sensitivity is paired with a clear sense of self.',
    'Absorbing other people’s moods may be blurring the line between compassion and responsibility, leaving your own emotional state difficult to hear.',
    'Feel what is present, name what is yours, and let one boundary protect your capacity to care.',
  ],
  'King of Cups': [
    'Emotional steadiness allows strong feeling to inform a response without controlling it, creating space for compassion, honesty, and mature restraint.',
    'Composure may be turning into emotional control or avoidance if difficult feelings are managed so tightly that nobody can actually meet you.',
    'Name the feeling calmly, choose the response deliberately, and resist the urge to rescue or suppress.',
  ],

  'Ace of Swords': [
    'A clean insight can cut through confusion when you separate what is known from what is assumed and are willing to act on the clearer truth.',
    'Certainty may be arriving faster than understanding, turning a useful insight into a weapon, verdict, or decision made before enough evidence exists.',
    'State the clearest fact you know and the most important question that still remains open.',
  ],
  'Two of Swords': [
    'A protected pause can help you choose, but the decision becomes possible only when you identify the criteria that matter more than temporary comfort.',
    'Avoidance may be wearing the appearance of neutrality, keeping you between options because choosing would expose a cost you do not want to face.',
    'Choose two decision criteria and use them to eliminate the option that least respects your values.',
  ],
  'Three of Swords': [
    'A painful truth, separation, or disappointment needs precise acknowledgment; clarity about the wound is the beginning of deciding what repair or distance requires.',
    'Rumination may be turning pain into identity, repeatedly reopening the injury without creating new information, protection, or repair.',
    'Name the hurt without exaggerating it and choose whether the next need is repair, support, or space.',
  ],
  'Four of Swords': [
    'Mental recovery is productive when rest is deliberate, because a quieter nervous system can see choices that constant effort keeps obscured.',
    'Withdrawal may have become stagnation or avoidance if the pause has no purpose, boundary, or point at which you will re-engage.',
    'Schedule a defined period of real rest and decide in advance what question you will return to afterward.',
  ],
  'Five of Swords': [
    'Conflict is exposing the true cost of winning, asking whether the outcome is worth the damage to trust, dignity, or future cooperation.',
    'Humiliation, revenge, or the need to be right may be keeping a battle alive after the useful information has already been revealed.',
    'Ask what victory would cost and choose one move that lowers unnecessary harm without abandoning your boundary.',
  ],
  'Six of Swords': [
    'A difficult transition can become lighter when you accept that progress may look quiet, practical, and incomplete before it feels emotionally resolved.',
    'You may be physically moving on while carrying the old argument internally, recreating the same turbulence in a new setting.',
    'Simplify the passage and deliberately leave behind one thought, object, or obligation that belongs to the old chapter.',
  ],
  'Seven of Swords': [
    'Strategy and privacy can be wise when they protect timing and autonomy without requiring you to distort the truth or exploit someone else’s blind spot.',
    'Secrecy may be sliding into deception or self-deception, especially if avoiding accountability has become the real purpose of the plan.',
    'Decide what genuinely needs privacy and what must become transparent for the situation to remain ethical.',
  ],
  'Eight of Swords': [
    'The situation contains real limits, but at least one part of the trap may be an assumption that has not yet been tested against current reality.',
    'Fear and learned helplessness may be presenting every constraint as permanent, making inaction feel like the only responsible choice.',
    'List what is truly fixed and test one restriction that might be more negotiable than it appears.',
  ],
  'Nine of Swords': [
    'Anxiety deserves care because the mind is carrying a threat long after the useful planning has ended; separating facts from feared scenarios can restore proportion.',
    'Catastrophizing or private shame may be intensifying distress by treating imagined outcomes as evidence and isolation as protection.',
    'Write down the facts, the feared story, and one source of support you can contact instead of rehearsing the fear alone.',
  ],
  'Ten of Swords': [
    'A painful ending has reached a point where repeatedly negotiating with what is finished costs more than beginning the slow work of recovery.',
    'Dramatizing the ending or refusing closure may keep you attached to the moment of defeat instead of the choices that become possible afterward.',
    'Stop reopening one completed decision and put that energy into a concrete recovery step.',
  ],
  'Page of Swords': [
    'Alert curiosity can uncover useful information when questions are asked directly and evidence is checked before a fast mind builds a conclusion.',
    'Hypervigilance, gossip, or constant scanning may be creating a sense of knowledge without the reliability that comes from verification.',
    'Verify the most important claim before reacting, sharing it, or building another assumption on top of it.',
  ],
  'Knight of Swords': [
    'Fast thinking and decisive communication can break a stalemate when the goal is clarity and the consequences of speed are understood.',
    'Aggression may be hiding inside urgency, turning a legitimate point into an argument that values victory over understanding.',
    'Slow down by one beat, state the point cleanly, and remove any sentence whose only purpose is to win.',
  ],
  'Queen of Swords': [
    'Discernment allows you to be compassionate without becoming vague; a clean boundary can protect truth and respect at the same time.',
    'Independence may be hardening into cynicism or emotional distance if disappointment has made tenderness feel intellectually unsafe.',
    'Give one clear yes or no without punishment, over-explaining, or pretending you feel less than you do.',
  ],
  'King of Swords': [
    'Reason, ethics, and disciplined judgment can create trustworthy authority when the same standard is applied even when it is inconvenient.',
    'Intellectual control may be replacing wisdom if rules, expertise, or status are used to silence complexity rather than clarify it.',
    'Name the principle guiding the decision and apply it consistently to yourself as well as everyone else.',
  ],

  'Ace of Pentacles': [
    'A tangible opportunity is asking to become real through resources, work, health, or material support; its promise depends on the foundation you actually build.',
    'A useful opening may be missed through poor preparation, scarcity thinking, or attraction to the idea of security without practical follow-through.',
    'Make the opportunity concrete by assigning it a first resource, date, or measurable action.',
  ],
  'Two of Pentacles': [
    'Adaptability is helping you manage competing demands, but sustainable balance depends on knowing which priority cannot keep being treated as equally urgent.',
    'Constant juggling may have become normalized overload, leaving no buffer for mistakes, rest, or the next unexpected demand.',
    'Choose the true priority and create one small buffer of time, money, or energy around it.',
  ],
  'Three of Pentacles': [
    'Skill grows faster when roles, feedback, and standards are visible; collaboration works best when contribution matters more than status.',
    'Poor coordination or ego may be weakening otherwise strong work, especially if people are contributing without a shared definition of quality.',
    'Clarify your role, the shared standard, and the next piece of feedback needed before more work is added.',
  ],
  'Four of Pentacles': [
    'Protecting resources can create healthy stability when security serves your life rather than becoming the reason you refuse every meaningful risk.',
    'Scarcity fear may be tightening into control, hoarding, or attachment, making possession feel safer than circulation, trust, or growth.',
    'Protect what is essential and loosen one hold that exists mainly because loss feels frightening.',
  ],
  'Five of Pentacles': [
    'Material or physical strain can make support difficult to see, but hardship is easier to address when need is named without shame or isolation.',
    'Feeling excluded or behind may be convincing you to withdraw from exactly the people, services, or resources that could reduce the pressure.',
    'Make an honest inventory of available support and ask for one specific form of help.',
  ],
  'Six of Pentacles': [
    'Giving and receiving become healthy when the exchange is transparent, proportionate, and preserves dignity on both sides.',
    'Generosity may carry hidden strings, or receiving may feel unsafe because power, debt, or obligation has not been spoken about clearly.',
    'Make the terms of one exchange explicit and check whether both sides can genuinely consent to them.',
  ],
  'Seven of Pentacles': [
    'Patience is useful when it includes evaluation; accumulated effort deserves an evidence-based review before you simply invest more because you already have.',
    'Frustration or sunk-cost thinking may be keeping you tied to an approach whose return no longer justifies the resources it consumes.',
    'Review the evidence and decide deliberately whether to continue, adjust, or stop one investment of effort.',
  ],
  'Eight of Pentacles': [
    'Repetition is becoming mastery when practice remains attentive, measurable, and open to feedback rather than merely accumulating hours.',
    'Perfectionism or grind may be turning craft into mechanical labor, where more effort replaces curiosity about what would actually improve the result.',
    'Choose one skill, practice it deliberately, and obtain one concrete piece of feedback.',
  ],
  'Nine of Pentacles': [
    'Earned independence can be enjoyed without apology; competence and self-support are creating room for pleasure, choice, and a more deliberate pace.',
    'Self-sufficiency may be becoming isolation or status performance if needing nobody feels safer than allowing mutual dependence.',
    'Enjoy what you have built and maintain one connection that does not depend on proving your independence.',
  ],
  'Ten of Pentacles': [
    'Long-term stability is shaped by what is passed forward: resources, habits, values, knowledge, and the structures that can outlast a single moment.',
    'Inherited expectations or status may be defining success for you, creating loyalty to a legacy that does not fully fit the life you want.',
    'Name what you genuinely want to preserve and one inherited expectation you are willing to revise.',
  ],
  'Page of Pentacles': [
    'A practical learning opportunity wants commitment to basics; curiosity becomes valuable when it is attached to a plan, resource, and real practice.',
    'Procrastination or inexperience may be hidden beneath endless preparation, collecting information without risking the feedback of doing the work.',
    'Turn the interest into a simple study-and-practice plan with one measurable first task.',
  ],
  'Knight of Pentacles': [
    'Consistency is the advantage now; reliable progress may look unremarkable from day to day while quietly building something difficult to replace.',
    'Routine may have become rigidity or stagnation if diligence continues after the process stops serving the actual goal.',
    'Keep the useful cadence and change one inefficient step instead of abandoning the whole system.',
  ],
  'Queen of Pentacles': [
    'Grounded care can make resources, body, home, and work feel more sustainable when nurturing includes the person providing the care.',
    'Over-functioning may be disguising self-neglect, with competence becoming the reason everyone else’s needs arrive before your own.',
    'Meet one practical need for others and one for yourself with the same standard of care.',
  ],
  'King of Pentacles': [
    'Stewardship turns resources into durable value when leadership protects stability, quality, and the people affected by material decisions.',
    'Status, ownership, or control may be replacing stewardship if accumulation matters more than usefulness, fairness, or long-term resilience.',
    'Measure success by the durable value and shared stability your resources create, not only by what you possess.',
  ],
};
