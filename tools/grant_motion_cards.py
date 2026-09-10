import math, os, subprocess, sys
from PIL import Image, ImageDraw, ImageFont

W,H,FPS=1920,1080,30
BG=(10,13,18); PANEL=(20,25,33); PANEL2=(25,31,40); WHITE=(242,244,247); MUTED=(154,164,176); GOLD=(233,185,73); GOLD2=(194,145,43); RED=(214,92,92); GREEN=(108,188,148); GRID=(40,47,57)
FONT_B='/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
FONT_R='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'

FB=lambda s: ImageFont.truetype(FONT_B,s)
FR=lambda s: ImageFont.truetype(FONT_R,s)

def clamp(x,a=0,b=1): return max(a,min(b,x))
def ease(x):
    x=clamp(x); return 1-(1-x)**3

def rr(d,xy,r,fill,outline=None,width=1): d.rounded_rectangle(xy,radius=r,fill=fill,outline=outline,width=width)

def text(d,xy,s,font,fill=WHITE,anchor='la'):
    d.text(xy,s,font=font,fill=fill,anchor=anchor)

def center(d,y,s,font,fill=WHITE):
    d.text((W//2,y),s,font=font,fill=fill,anchor='ma')

def base_frame(kicker,title,sub=''):
    im=Image.new('RGB',(W,H),BG); d=ImageDraw.Draw(im)
    # subtle grid
    for x in range(80,W,120): d.line((x,0,x,H),fill=GRID,width=1)
    for y in range(70,H,120): d.line((0,y,W,y),fill=GRID,width=1)
    d.rectangle((0,0,W,8),fill=GOLD)
    text(d,(110,92),kicker.upper(),FB(28),GOLD)
    text(d,(110,148),title,FB(64),WHITE)
    if sub: text(d,(112,230),sub,FR(30),MUTED)
    return im,d

def encode(name,duration,render):
    frames=round(duration*FPS)
    cmd=['ffmpeg','-hide_banner','-loglevel','error','-y','-f','rawvideo','-pix_fmt','rgb24','-s',f'{W}x{H}','-r',str(FPS),'-i','-','-an','-c:v','libx264','-profile:v','main','-preset','veryfast','-crf','16','-pix_fmt','yuv420p','-r',str(FPS),'-movflags','+faststart',name]
    p=subprocess.Popen(cmd,stdin=subprocess.PIPE)
    try:
        for n in range(frames):
            t=n/FPS
            im=render(t,duration)
            p.stdin.write(im.tobytes())
    finally:
        if p.stdin: p.stdin.close()
    rc=p.wait()
    if rc: raise SystemExit(f'ffmpeg failed {name}: {rc}')

def compounding(t,dur):
    im,d=base_frame('WEALTH SYSTEM','Compounding starts quietly.','The curve changes after the habit survives.')
    # chart panel
    rr(d,(170,330,1750,930),34,PANEL)
    # axes
    d.line((320,810,1570,810),fill=MUTED,width=3); d.line((320,420,320,810),fill=MUTED,width=3)
    labels=['YEAR 1','YEAR 3','YEAR 5','YEAR 8','YEAR 12']
    heights=[75,120,190,285,385]
    xs=[430,650,870,1090,1310]
    for i,(x,hh,lab) in enumerate(zip(xs,heights,labels)):
        start=0.35+i*0.55; prog=ease((t-start)/0.85)
        h=int(hh*prog)
        d.rounded_rectangle((x,810-h,x+110,810),radius=18,fill=GOLD if i==4 else (196,164,92))
        text(d,(x+55,850),lab,FR(23),MUTED,'ma')
        if prog>.92: text(d,(x+55,780-h),f'{[1.0,1.3,1.8,2.7,4.1][i]:.1f}×',FB(25),WHITE,'ma')
    # curve between tops, revealed progressively
    pts=[(x+55,810-h) for x,h in zip(xs,heights)]
    reveal=clamp((t-2.0)/2.2)
    segs=[]
    for i in range(len(pts)-1):
        local=clamp(reveal*4-i)
        if local<=0: break
        a,b=pts[i],pts[i+1]
        q=(int(a[0]+(b[0]-a[0])*local),int(a[1]+(b[1]-a[1])*local))
        segs.append((a,q))
    for a,b in segs: d.line((*a,*b),fill=WHITE,width=7)
    pulse=1+0.08*math.sin(t*5)
    if t>4.15:
        rr(d,(1160,350,1580,425),20,(44,39,25),outline=GOLD,width=2)
        text(d,(1370,388),'MOMENTUM',FB(int(30*pulse)),GOLD,'mm')
    return im

def emergency(t,dur):
    im,d=base_frame('RISK FIRST','Build the buffer before the upside.','Emergency fund = time to make a better decision.')
    rr(d,(210,360,1710,865),34,PANEL)
    # six monthly blocks
    for i in range(6):
        x=340+i*210; start=.4+i*.55; prog=ease((t-start)/.55)
        y0=650; y1=650-int(170*prog)
        rr(d,(x,y1,x+150,650),20,GOLD if prog>.05 else PANEL2)
        text(d,(x+75,700),f'M{i+1}',FB(24),WHITE,'ma')
    # progress rail
    rr(d,(340,760,1510,796),18,PANEL2)
    p=ease((t-.45)/4.2); x2=340+int(1170*p)
    rr(d,(340,760,x2,796),18,GOLD)
    text(d,(340,835),'3–6 MONTHS OF EXPENSES',FB(30),WHITE)
    # shield on right top
    cx,cy=1510,500; s=ease((t-3.2)/.7)
    if s>0:
        poly=[(cx,cy-75*s),(cx+68*s,cy-42*s),(cx+55*s,cy+48*s),(cx,cy+90*s),(cx-55*s,cy+48*s),(cx-68*s,cy-42*s)]
        d.polygon(poly,fill=(44,39,25),outline=GOLD)
        d.line((cx-28*s,cy+5*s,cx-5*s,cy+30*s,cx+38*s,cy-22*s),fill=GOLD,width=max(1,int(9*s)),joint='curve')
    return im

def market(t,dur):
    phase=0 if t<6.2 else (1 if t<12.3 else 2)
    if phase==0:
        im,d=base_frame('VOLATILITY','Markets drop.','A falling chart feels louder than a long-term plan.')
    elif phase==1:
        im,d=base_frame('BEHAVIOR','Panic turns volatility into a loss.','The hardest move is often doing less.')
    else:
        im,d=base_frame('DISCIPLINE','Stay invested through the noise.','Volatility is not the same thing as failure.')
    rr(d,(165,335,1755,920),34,PANEL)
    # phase transition wipe
    local=t-[0,6.2,12.3][phase]
    # chart area
    x0,y0,x1,y1=300,430,1600,790
    d.line((x0,y1,x1,y1),fill=MUTED,width=2); d.line((x0,y0,x0,y1),fill=MUTED,width=2)
    vals = ([0.72,0.68,0.58,0.52,0.42,0.36,0.30,0.28,0.31] if phase==0 else
            [0.62,0.54,0.45,0.35,0.30,0.28,0.27,0.29,0.31] if phase==1 else
            [0.31,0.33,0.37,0.43,0.48,0.56,0.63,0.70,0.77])
    pts=[]
    for i,v in enumerate(vals):
        x=x0+i*(x1-x0)/(len(vals)-1); y=y1-v*(y1-y0)
        pts.append((int(x),int(y)))
    reveal=ease(local/3.0)
    count=max(2,int(1+reveal*(len(pts)-1)))
    for i in range(count-1):
        d.line((*pts[i],*pts[i+1]),fill=(RED if phase<2 else GREEN),width=9)
        d.ellipse((pts[i][0]-7,pts[i][1]-7,pts[i][0]+7,pts[i][1]+7),fill=WHITE)
    if count==len(pts): d.ellipse((pts[-1][0]-9,pts[-1][1]-9,pts[-1][0]+9,pts[-1][1]+9),fill=GOLD)
    if phase==0:
        text(d,(330,835),'PRICE',FR(22),MUTED); text(d,(1460,835),'TIME',FR(22),MUTED)
        if local>3.4: text(d,(1430,470),'DROP ≠ END',FB(28),GOLD,'ma')
    elif phase==1:
        a=ease((local-2.2)/.6)
        if a>0:
            rr(d,(560,800,1360,880),20,(49,27,30),outline=RED,width=2)
            text(d,(960,840),'SELLING LOW LOCKS IT IN',FB(int(31+4*a)),WHITE,'mm')
    else:
        a=ease((local-2.0)/.7)
        if a>0:
            rr(d,(560,800,1360,880),20,(28,45,37),outline=GREEN,width=2)
            text(d,(960,840),'PLAN > PANIC',FB(int(34+3*a)),WHITE,'mm')
    return im

def income(t,dur):
    # 4 editorial chapters inside one 40.4s block
    if t<9.6:
        im,d=base_frame('DECISION','Debt vs. investing.','Compare the cost before chasing the return.')
        rr(d,(170,355,875,885),32,PANEL); rr(d,(1045,355,1750,885),32,PANEL)
        center_y=455
        text(d,(522,445),'HIGH-COST DEBT',FB(34),RED,'ma'); text(d,(1398,445),'INVESTING',FB(34),GOLD,'ma')
        p=ease(t/5.4)
        debt=max(0,100-int(62*p)); inv=100+int(38*p)
        text(d,(522,590),f'{debt}',FB(104),WHITE,'mm'); text(d,(1398,590),f'{inv}',FB(104),WHITE,'mm')
        text(d,(522,690),'COST',FR(24),MUTED,'ma'); text(d,(1398,690),'GROWTH',FR(24),MUTED,'ma')
        rr(d,(400,770,1520,824),26,PANEL2)
        xpos=400+int(1120*p)
        rr(d,(400,770,xpos,824),26,GOLD)
        text(d,(960,850),'COMPARE THE MATH',FB(28),WHITE,'ma')
    elif t<20.2:
        local=t-9.6
        im,d=base_frame('RESILIENCE','Build multiple income streams.','One paycheck should not carry every risk.')
        cx,cy=960,660
        nodes=[('SALARY',470,520),('SKILLS',470,760),('BUSINESS',1450,520),('INVESTMENTS',1450,760)]
        for i,(lab,x,y) in enumerate(nodes):
            p=ease((local-i*.9)/.7)
            if p>0:
                # connector
                d.line((cx,cy,x,y),fill=(70,76,86),width=max(1,int(7*p)))
                r=int(100*p); d.ellipse((x-r,y-r,x+r,y+r),fill=PANEL,outline=GOLD,width=max(1,int(4*p)))
                text(d,(x,y),lab,FB(max(14,int(24*p))),WHITE,'mm')
        p=ease((local-3.6)/.8); r=int(138*p)
        if p>0:
            d.ellipse((cx-r,cy-r,cx+r,cy+r),fill=(44,39,25),outline=GOLD,width=5)
            text(d,(cx,cy-15),'INCOME',FB(max(16,int(34*p))),GOLD,'mm'); text(d,(cx,cy+34),'SYSTEM',FB(max(16,int(34*p))),WHITE,'mm')
    elif t<30.5:
        local=t-20.2
        im,d=base_frame('DIVERSIFY','Shift the weight over time.','The goal is not more chaos — it is less dependence.')
        labels=[('SALARY',0.70),('SKILLS',0.12),('BUSINESS',0.10),('INVESTMENTS',0.08)]
        target=[0.42,0.18,0.22,0.18]
        y=445
        for i,((lab,a),b) in enumerate(zip(labels,target)):
            p=ease(local/7.2); val=a+(b-a)*p
            text(d,(300,y+i*105),lab,FB(28),WHITE)
            rr(d,(610,y-6+i*105,1540,y+44+i*105),24,PANEL2)
            rr(d,(610,y-6+i*105,610+int(930*val),y+44+i*105),24,GOLD if i else (185,160,104))
            text(d,(1585,y+18+i*105),f'{round(val*100)}%',FB(24),MUTED,'lm')
    else:
        local=t-30.5
        im,d=base_frame('RISK','One source is fragile.','Streams that work together create resilience.')
        # left single-source tower cracks, right diversified nodes
        rr(d,(240,380,820,875),32,PANEL); rr(d,(1100,380,1680,875),32,PANEL)
        text(d,(530,445),'ONE SOURCE',FB(31),WHITE,'ma'); text(d,(1390,445),'MULTIPLE STREAMS',FB(31),WHITE,'ma')
        # left pillar
        shake=0 if local<4 else int(10*math.sin(local*15))
        rr(d,(450+shake,540,610+shake,780),26,(73,67,54),outline=GOLD,width=3)
        if local>4:
            d.line((500+shake,560,555+shake,635,515+shake,690,570+shake,755),fill=RED,width=8)
        # right nodes feed core
        cx,cy=1390,680
        d.ellipse((cx-80,cy-80,cx+80,cy+80),fill=(44,39,25),outline=GOLD,width=4)
        for i,(dx,dy) in enumerate([(-190,-120),(190,-120),(-190,120),(190,120)]):
            p=ease((local-.5-i*.5)/.5); x=cx+dx; y=cy+dy
            if p>0:
                d.line((x,y,cx,cy),fill=GOLD,width=max(1,int(6*p)))
                r=int(38*p); d.ellipse((x-r,y-r,x+r,y+r),fill=WHITE)
        if local>5.8:
            text(d,(1390,680),'RESILIENT',FB(24),GOLD,'mm')
        if local>7.0:
            rr(d,(610,920,1310,982),20,(44,39,25),outline=GOLD,width=2)
            text(d,(960,951),'MULTIPLE STREAMS WORK TOGETHER',FB(27),WHITE,'mm')
    return im

if __name__=='__main__':
    os.makedirs('motion',exist_ok=True)
    encode('motion/compounding.mp4',5.6,compounding)
    encode('motion/emergency.mp4',6.1,emergency)
    encode('motion/market.mp4',19.1,market)
    encode('motion/income.mp4',40.4,income)
    print('MOTION_CLIPS_DONE')
