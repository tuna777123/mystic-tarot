export type Motion = 'push' | 'pull' | 'pan_left' | 'pan_right';
export type Crop = 'tl' | 'tr' | 'bl' | 'br';

export type Shot = {
  start: number;
  end: number;
  asset: string;
  motion: Motion;
  reconstruction?: boolean;
  crop?: Crop;
  objectPosition?: string;
};

export type Caption = {start: number; end: number; text: string};

export const proofShots: Shot[] = [
  {start:0,end:3.233,asset:'Abandoned Classroom with Open Book.png',motion:'push'},
  {start:3.233,end:6.5,asset:'Forgotten Lessons in an Abandoned Classroom.png',motion:'pan_left'},
  {start:6.5,end:9.733,asset:'The Street They Left Behind.png',motion:'pan_right'},
  {start:9.733,end:12,asset:'Houtouwan Reclaimed by Nature.png',motion:'pull'},
  {start:12,end:14.767,asset:'Buses line Pripyat for evacuation.png',motion:'push',reconstruction:true,objectPosition:'44% 50%'},
  {start:14.767,end:17.633,asset:"Smoke Beneath Centralia's Cracked Road.png",motion:'pan_right'},
  {start:17.633,end:20.167,asset:'Villa Epecuén Beneath the Floodwaters.png',motion:'push',reconstruction:true,objectPosition:'50% 44%'},
  {start:20.167,end:23.433,asset:'Ordinary Life in Pripyat, 1985.png',motion:'pan_left',reconstruction:true},
  {start:23.433,end:26.743,asset:'Pripyat’s Silent Ferris Wheel.png',motion:'pull'},
  {start:26.743,end:28.634,asset:"Pripyat's Empty Avenue and Rusted Ferris Wheel.png",motion:'push'},

  // Five unique escalation shots — no exact still reuse in the hook.
  // Short montage shots use restrained push/pull instead of long-distance pans.
  {start:28.634,end:29.934,asset:'Beneath the Maunsell Sea Forts.png',motion:'pull'},
  {start:29.934,end:31.234,asset:'Buzludzha in winter fog.png',motion:'push'},
  {start:31.234,end:32.534,asset:'Centralia mine fire, four documentary views.png',motion:'pull',reconstruction:true,crop:'br'},
  {start:32.534,end:33.851,asset:'Plymouth Buried in Volcanic Ash.png',motion:'push',reconstruction:true,crop:'tl'},

  // Chapter reveal holds on one clean hero shot instead of bouncing between repeated stills.
  {start:33.851,end:37.467,asset:'Maunsell Sea Forts in Grey Mist.png',motion:'pull',objectPosition:'58% 48%'},

  // 12 consecutive Maunsell shots, 12 distinct source images. Historical synthetic scenes are labelled.
  {start:37.467,end:40.867,asset:'Rusting Catwalk at Maunsell Sea Fort.png',motion:'pan_left'},
  {start:40.867,end:44.3,asset:'Maunsell Sea Forts in Grey Mist.png',motion:'push'},
  {start:44.3,end:48.767,asset:'Maunsell Wartime Gun Reconstruction.png',motion:'pull',reconstruction:true},
  {start:48.767,end:53.367,asset:'Maunsell Fort Anti-Aircraft Gun, 1943.png',motion:'pan_right',reconstruction:true},
  {start:53.367,end:58,asset:'Dawn Watch on the Thames Sea Fort.png',motion:'push',reconstruction:true},
  {start:58,end:61.133,asset:'Maunsell Postwar Empty Gun Mount Reconstruction.png',motion:'pull',reconstruction:true},
  {start:61.133,end:65.333,asset:'Pirate Radio Inside a Sea Fort.png',motion:'pan_left',reconstruction:true},
  {start:65.333,end:69.5,asset:'1960s Pirate Radio in a Sea Fort.png',motion:'push',reconstruction:true},
  {start:69.5,end:73.433,asset:'Maunsell Pirate Radio Detail Reconstruction.png',motion:'pull',reconstruction:true},
  {start:73.433,end:76,asset:'Maunsell Understructure Reconstruction.png',motion:'pan_right',reconstruction:true},
  {start:76,end:80.5,asset:'Corroded Catwalk Between Maunsell Towers.png',motion:'push'},
  {start:80.5,end:85,asset:'Beneath the Maunsell Sea Forts.png',motion:'pull'},

  // Houtouwan chapter opens on three unique sources — no repeated hero still.
  {start:85,end:86.545,asset:'Misty Shoreline Above Abandoned Houtouwan.png',motion:'pull'},
  {start:86.545,end:88.08,asset:"Houtouwan's Ivy-Swallowed Fishing Village.png",motion:'push'},
  {start:88.08,end:90,asset:'Ivy-reclaimed room overlooking Houtouwan coast.png',motion:'pan_left'}
];

// V19 speech-timed cue boundaries remain the timing source of truth.
export const proofCaptions: Caption[] = [
  {start:0,end:4.279,text:'Imagine returning to your hometown and finding dinner plates still'},
  {start:4.279,end:8.559,text:'on tables, schoolbooks left behind, and entire streets with no one'},
  {start:8.559,end:9.726,text:'left to walk them.'},
  {start:9.726,end:12.011,text:'Some places emptied slowly.'},
  {start:12.011,end:14.781,text:'Others lost everyone in a single day.'},
  {start:14.781,end:17.642,text:'One town is still burning beneath the ground.'},
  {start:17.642,end:20.151,text:'Another disappeared beneath a lake.'},
  {start:20.151,end:24.393,text:'And in the number one location, almost fifty thousand people were'},
  {start:24.393,end:26.743,text:'told they would be home within days.'},
  {start:26.743,end:28.634,text:'They never returned.'},
  {start:28.634,end:31.7,text:'These are twenty places everyone abandoned...'},
  {start:31.7,end:33.851,text:'and the dark reasons why.'},
  {start:33.851,end:35.254,text:'Number twenty.'},
  {start:35.254,end:37.45,text:'The Maunsell Sea Forts.'},
  {start:37.45,end:41.716,text:'Rising from the waters of the Thames Estuary, these rusting towers'},
  {start:41.716,end:44.301,text:'look like the remains of a drowned city.'},
  {start:44.301,end:48.245,text:'They were built during World War Two to defend Britain from German'},
  {start:48.245,end:48.783,text:'aircraft.'},
  {start:48.783,end:53.842,text:'Each fort consisted of armed steel towers connected by narrow'},
  {start:53.842,end:57.988,text:'walkways, with soldiers living high above the sea.'},
  {start:57.988,end:61.122,text:'After the war, the weapons were removed and the crews went home.'},
  {start:61.122,end:64.978,text:'Some towers were later occupied by pirate radio stations,'},
  {start:64.978,end:69.51,text:'broadcasting illegal music from beyond British territorial control.'},
  {start:69.51,end:73.433,text:'But eventually, even those voices disappeared.'},
  {start:73.433,end:76.013,text:'Today, the forts stand empty.'},
  {start:76.013,end:80.009,text:'Their walkways have collapsed, their metal shells are slowly'},
  {start:80.009,end:84.204,text:'corroding, and the only permanent sound is the sea striking the'},
  {start:84.204,end:85.003,text:'steel below.'},
  {start:85.003,end:86.545,text:'Number nineteen.'},
  {start:86.545,end:88.08,text:'Houtouwan.'},
  {start:88.08,end:90,text:'Hidden on a remote island off the coast of China, Houtouwan was'}
];
