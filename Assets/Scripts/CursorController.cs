using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using static UnityEditor.PlayerSettings;

public class CursorController : MonoBehaviour
{

    public GameObject SelectObject;
    public Sprite SelectSprite;
    public GameObject ChooseObject;
    public Sprite ChooseSprite;
    private MapCreater MapCreater;
    private BaseMapTemplate MapTemplate;
    private Vector3 OldMousePosition;
    private DateTime SelectBeforeDT;
    private CameraController CameraController;
    private RoundController RoundController;
    private UnitController UnitController;
    // Start is called before the first frame update
    void Start()
    {
        SelectBeforeDT = System.DateTime.Now;
        OldMousePosition = Input.mousePosition;
        SpriteRenderer spriteRenderer = SelectObject.GetComponent<SpriteRenderer>();
        spriteRenderer.sprite = null;
        MapCreater = GameObject.Find("MapManager").GetComponent<MapCreater>();
        MapTemplate = MapCreater.GetMapTemplate();
        CameraController = GameObject.Find("CameraController").GetComponent<CameraController>();
        RoundController = GameObject.Find("RoundController").GetComponent<RoundController>();
        UnitController = GameObject.Find("UnitController").GetComponent<UnitController>();

        //selectObject.SetActive(false);
        //selectObject = GameObject.Find("SelectObject");
    }

    // Update is called once per frame
    void Update()
    {
        //Debug.Log(RoundController.GetAnimaPlay());
        if(
            RoundController.GetRoundStatus()!= RoundStatus.unitControl
            || RoundController.GetAnimaPlay()
            )
        {
            return;
        }
        CursorControl();
        ChooseControl();

    }

    

    private void CursorControl()
    {
        Vector3 mousePosition = Input.mousePosition;
        SpriteRenderer spriteRenderer = SelectObject.GetComponent<SpriteRenderer>();
        if (OldMousePosition.x != mousePosition.x || OldMousePosition.y != mousePosition.y)
        {
            OldMousePosition = mousePosition;
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit[] hits = Physics.RaycastAll(ray);
            foreach (RaycastHit hit in hits)
            {
                if (hit.collider.gameObject.transform.parent==null) 
                {
                    continue;
                }
                if ("FloorBase" == hit.collider.gameObject.transform.parent.name)
                {
                    spriteRenderer.sprite = SelectSprite;
                    Vector3 pos = hit.collider.gameObject.transform.position;
                    SelectObject.transform.position = new Vector3(pos.x, pos.y+1.10f, pos.z);
                    return;
                }
                else
                {
                    //spriteRenderer.sprite = null;
                }
            }         
        }
        else
        {
            float horizontal = Input.GetAxis("Horizontal");
            float vertical = Input.GetAxis("Vertical");
            if (horizontal != 0f || vertical != 0f)
            {
                spriteRenderer.sprite = SelectSprite;
                float absHorizontal = Math.Abs(horizontal);
                float absVertical = Math.Abs(vertical);
                float abs = absHorizontal > absVertical? absHorizontal: absVertical;
                Vector3 pos = SelectObject.transform.position;
                DateTime afterDT = System.DateTime.Now;
                TimeSpan timespan = afterDT.Subtract(SelectBeforeDT);
                double minMill = 300;
                if (abs>0.5) {
                    minMill = 100;
                }
                if (timespan.Milliseconds > minMill)
                {
                    
                    if (horizontal > 0f)
                    {
                        SelectTranslate(1, 0);

                    }
                    else if (horizontal < 0f)
                    {
                        SelectTranslate(-1, 0);

                    }
                    if (vertical > 0f)
                    {
                        SelectTranslate(0, 1);

                    }
                    else if (vertical < 0f)
                    {
                        SelectTranslate(0, -1);

                    }
                }
            }
            
            
            
            
            
            
        }
        
    }

    private void SelectTranslate(int horizontal,int vertical) {
        
        double cameraRotationY = CameraController.GetCinemachine().transform.localEulerAngles.y;
        //Debug.Log(cameraRotationY);
        int x = 0;
        int z = 0;
        Vector3 pos = SelectObject.transform.position;
        if (-22.5 <= cameraRotationY && cameraRotationY <= 22.5)
        {
            x = horizontal;
            z = vertical;
        } else if (cameraRotationY <= 112.5 && cameraRotationY >= 22.5) {
            x = vertical;
            z = horizontal*-1;
        }else if (cameraRotationY >= 112.5 && cameraRotationY <= 202.5)
        {
            x = horizontal * -1;
            z = vertical * -1;
        }
        else if (cameraRotationY >= 202.5)
        {
            x = vertical * -1;
            z = horizontal ;
        }
        GameObject[,]  coods = MapCreater.GetCoords();
        if (pos.x + x+1 >= coods.GetLength(0) || pos.z + z + 1 >= coods.GetLength(1))
        {
            return;
        }
        SelectObject.transform.position = new Vector3(pos.x + x, pos.y, pos.z + z);
        DateTime afterDT = System.DateTime.Now;
        SelectBeforeDT = afterDT;
    }

    private void ChooseControl()
    {
        SpriteRenderer spriteRenderer = ChooseObject.GetComponent<SpriteRenderer>();
        if (Input.GetButtonDown("ButtonA"))
        {
            Vector3 selectPos = SelectObject.transform.position;
            ChooseObject.transform.position
                = new Vector3(selectPos.x, selectPos.y + 0.01f, selectPos.z);
            spriteRenderer.sprite = ChooseSprite;
            if (UnitController.ChooseObject != null)
            {
                UnitController.UnitMove(new Vector3(selectPos.x, selectPos.y - 0.1f, selectPos.z));
            }
            else
            {
                RaycastHit[] hits = Physics.RaycastAll(new Vector3(selectPos.x, 0, selectPos.z)
                                , new Vector3(selectPos.x, 100, selectPos.z)
                                , 1000F);
                foreach (RaycastHit hit in hits)
                {
                    if (hit.collider.gameObject.tag != "Unit")
                    {
                        continue;
                    }
                    UnitController.ChooseObject = hit.collider.gameObject;
                    //Debug.Log(UnitController.ChooseObject.name);
                    return;
                }
            }

        }
        if (Input.GetButtonDown("ButtonB"))
        {
            spriteRenderer.sprite = null;
            UnitController.ChooseObject = null;
        }
    }
}
