import csv
import os
import xml.etree.ElementTree as ET

path_to_eaf = 'data'
files = os.listdir(path_to_eaf)


annotations =[]
for file in files:
    f = open(path_to_eaf + '/' + file, "r", encoding='utf8')
    text = f.read()

    root = ET.fromstring(text)

    fieldnames =[]
    for tier in root.iter('TIER'):
        fieldname = tier.get('TIER_ID')
        fieldnames.append(fieldname)



    ids = []
    for tier in root.iter('TIER'):
        signs=tier.findall('[@TIER_ID="Sign"]')
        for j in signs:
            ann_count = j.findall('.//ANNOTATION_VALUE').__len__()
            if ann_count > 1:
                al_ann = j.findall('.//ALIGNABLE_ANNOTATION')
                for k in al_ann:
                    ids.append(k.get('ANNOTATION_ID'))
    #print(ids)

    if ids != []:
        for id in ids:
            #print (".//*[@ANNOTATION_REF='"+id+"']/ANNOTATION_VALUE")
            r2=[]
            for tier in root.iter('TIER'):
                l2=[]
                signnames = tier.findall(".//*[@ANNOTATION_ID='"+id+"']/ANNOTATION_VALUE")
                for val in signnames:
                    signname = val.text
                    l2.append(signname)
                #print (signname)

                anatations = tier.findall(".//*[@ANNOTATION_REF='"+id+"']/ANNOTATION_VALUE")
                for val in anatations:
                    #print(val.text)
                    if val.text == None:
                        l2.append('')
                    else:
                        l2.append(val.text)

                str2 = '; '.join(l2)
                r2.append(str2)

            #print(r2)
            annotations.append(r2)
    else:
        r2=[]
        for tier in root.iter('TIER'):
            anatations = tier.findall('.//ANNOTATION_VALUE')
            l2=[]
            for val in anatations:
                #print(val.text)
                if val.text == None:
                    l2.append('')
                else:
                    l2.append(val.text)

            str2 = '; '.join(l2)
            r2.append(str2)

        annotations.append(r2)

#print(annotations)
#print(fieldnames)

data=[]
for values in annotations:
    inner_dict = dict(zip(fieldnames, values))
    #print (inner_dict['H1 Focus'])
    #print (inner_dict["H1 Focus"])
    focus_list = inner_dict["H1 Focus"].split("; ")
    #print (focus_list)
    inner_dict["H1 Focus"] = focus_list[0]
    for i in focus_list[1:]:
        c = 2
        inner_dict["H1 Focus_"+c.__str__()] = i
        if fieldnames.count("H1 Focus_"+c.__str__())<1:
            fieldnames.append("H1 Focus_"+c.__str__())
        c = c+1

    facing_list = inner_dict["H1 Facing"].split("; ")
    #print (focus_list)
    inner_dict["H1 Facing"] = facing_list[0]
    for i in facing_list[1:]:
        #print (i)
        c = 2
        inner_dict["H1 Facing_"+c.__str__()] = i
        if fieldnames.count("H1 Facing_"+c.__str__())<1:
            fieldnames.append("H1 Facing_"+c.__str__())
        c = c+1

    finger_list = inner_dict["H1 FingerSelection"].split("; ")
    #print (focus_list)
    if finger_list.count("3-rd") and finger_list.count("1-st") and finger_list.count("2-nd") and finger_list.count("4-th"):
        #print (inner_dict["H1 FingerSelection"])
        if finger_list.count("thumb"):
            inner_dict["H1 FingerSelection"] = "all; thumb"
        else:
            inner_dict["H1 FingerSelection"] = "all"
    if finger_list.count("3-rd") and finger_list.count("1-st") and finger_list.count("2-nd") and len(finger_list) == 3:
        inner_dict["H1 FingerSelection"] = "1-st; 2-nd; 3-rd"
    if finger_list.count("thumb") and finger_list.count("1-st") and len(finger_list) == 2:
        inner_dict["H1 FingerSelection"] = "1-st; thumb"
    if finger_list.count("thumb") and finger_list.count("1-st") and finger_list.count("2-nd") and len(finger_list) == 3:
        inner_dict["H1 FingerSelection"] = "1-st; 2-nd; thumb"

    for key in inner_dict:
        if inner_dict[key] == '':
            inner_dict[key] = "absent"
            #print(key, inner_dict)


    data.append(inner_dict)


with open("dict_output.csv", "w", newline='') as out_file:
    writer = csv.DictWriter(out_file, delimiter=',', fieldnames=fieldnames)
    writer.writeheader()
    for row in data:
        writer.writerow(row)