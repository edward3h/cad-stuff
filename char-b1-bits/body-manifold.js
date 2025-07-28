const w = 42;
const h = 42;
const l = 88;

const ltoprear = l - 18;
const htoprear = h - 8;
const lbotrear =  l - 12;
const hbotrear = 9;

const lshrink = 1.7;
const ltotal = (705/lshrink) + 24 + 75;
const ltopfront = -24 *(l/ltotal);
const lmidfront = -(24+75) * (l/ltotal);

const htotal = 192;
const htopfront = h - (63 *(h/htotal));
const hmidfront = h - ((63+84) * (h/htotal));

const wright = w - (104*(w/188));
const ltopright = 72 *(l/ltotal);
const lmidright = ltopright - 127 * (l/ltotal);
const lbotright = ltopright - 5;

const hmidright = 20;

const leftside = new CrossSection([
    [
        [
            h,
            0
        ],
        [
            h,
            ltoprear
        ],
        [ htoprear, l],
        [ hbotrear, l],
        [ 0, lbotrear],
        [
            0,
            l
        ],
        [
            0,
            0
        ],
        [hmidfront,lmidfront],
        [htopfront,ltopfront]
    ]
]);

console.log(leftside.toPolygons());

const rightside = new CrossSection([[
  [0,lbotright],
  [0,lmidfront],
  [h,lmidfront],
  [h,ltopright],
  [hmidright,lmidright]
]])


const leftx = leftside.extrude(w).rotate([0,-90,0]);
const rightx = rightside.extrude(wright).rotate([0,-90,0]).translate([-w+wright,0,0]);
const result = leftx.subtract(rightx);
