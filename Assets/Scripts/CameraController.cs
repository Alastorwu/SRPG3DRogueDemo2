using Cinemachine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    private GameObject Cinemachine;
    private RoundController RoundController;
    private CinemachineVirtualCamera Vcam;
    private Cinemachine3rdPersonFollow Cinemachine3rdPersonFollow;
    private Vector3[] ShoulderOffset = new Vector3[4];
    private int ShoulderOffsetIndex = 0;
    private bool AngleSwitching = false;
    private float AngleSwitchSpeed = 6f;
    private Vector3 ShoulderOffGoal;

    public float zoomSpeed = 1f;

    void Awake()
    {
        ShoulderOffset[0] = new Vector3(0, 8, -8);
        //ShoulderOffset[1] = new Vector3(6, 8, -4);
        ShoulderOffset[1] = new Vector3(8, 8, 2);
        //ShoulderOffset[3] = new Vector3(6, 8, 4.25f);
        ShoulderOffset[2] = new Vector3(0, 8, 8);
        //ShoulderOffset[5] = new Vector3(-6, 8, 8);
        //ShoulderOffset[6] = new Vector3(-6, 8, 4);
        ShoulderOffset[3] = new Vector3(-8, 8, 2);
        ShoulderOffGoal = ShoulderOffset[0];

    }


    // Start is called before the first frame update
    void Start()
    {
        RoundController = GameObject.Find("RoundController").GetComponent<RoundController>();

    }

    public Cinemachine3rdPersonFollow GetCinemachine3rdPersonFollow()
    {
        return Cinemachine3rdPersonFollow;
    }
    public GameObject GetCinemachine()
    {
        return Cinemachine;
    }

    public bool PutTarget(GameObject target) 
    {
        GameObject[] units = GameObject.FindGameObjectsWithTag("Unit");
        GameObject unit = units[0];
        Cinemachine = GameObject.Find("CMvcam1");
        Vcam = Cinemachine.GetComponent<CinemachineVirtualCamera>();
        Vcam.m_LookAt = unit.transform;
        Vcam.m_Follow = unit.transform;
        Cinemachine3rdPersonFollow = Vcam.GetCinemachineComponent<Cinemachine3rdPersonFollow>();
        /*Cinemachine3rdPersonFollow transposer = vcam.GetCinemachineComponent<Cinemachine3rdPersonFollow>();
        transposer.ShoulderOffset = new Vector3(0,8,-6);*/
        return true;
    }


    // Update is called once per frame
    void Update()
    {
        if (
            RoundController.GetRoundStatus() != RoundStatus.unitControl
            || RoundController.GetAnimaPlay()
            )
        {
            return;
        }
        if (AngleSwitching)
        {
            AngleSwitch();
            return;
        }
        
        float scroll = Input.GetAxis("Mouse ScrollWheel");
        if (scroll != 0.0f)
        {
            Cinemachine3rdPersonFollow.ShoulderOffset.y -= scroll;
        }
        float mouseX = Input.GetAxis("Mouse X");
        float mouseY = Input.GetAxis("Mouse Y");

        if (Input.GetMouseButton(1)) {
            if (mouseX < 0) {
                ShoulderOffsetIndex++;
                if (ShoulderOffsetIndex >= ShoulderOffset.Length) {
                    ShoulderOffsetIndex = 0;
                }
                ShoulderOffGoal = ShoulderOffset[ShoulderOffsetIndex];
                AngleSwitching = true;
            } else if (mouseX > 0) {
                ShoulderOffsetIndex--;
                if (ShoulderOffsetIndex <0)
                {
                    ShoulderOffsetIndex = ShoulderOffset.Length-1;
                }
                ShoulderOffGoal = ShoulderOffset[ShoulderOffsetIndex];
                AngleSwitching = true;
            }
        }
    }

    
    private void AngleSwitch() 
    {
        Cinemachine3rdPersonFollow cinemachine3rdPersonFollow = Vcam.GetCinemachineComponent<Cinemachine3rdPersonFollow>();
        Vector3 shoulderOffset = cinemachine3rdPersonFollow.ShoulderOffset;
        float x = shoulderOffset.x;
        float y = shoulderOffset.y;
        float z = shoulderOffset.z;
        if (x > ShoulderOffGoal.x)
        {
            x -= Time.deltaTime * AngleSwitchSpeed;
            if (x< ShoulderOffGoal.x) { 
                x = ShoulderOffGoal.x;
            }
        }
        else if (x < ShoulderOffGoal.x)
        {
            x += Time.deltaTime * AngleSwitchSpeed;
            if (x > ShoulderOffGoal.x)
            {
                x = ShoulderOffGoal.x;
            }
        }
        if(y > ShoulderOffGoal.y) 
        {
            y -= Time.deltaTime * AngleSwitchSpeed;
            if (y < ShoulderOffGoal.y)
            {
                y = ShoulderOffGoal.y;
            }
        }
        else if(y < ShoulderOffGoal.y)
        {
            y += Time.deltaTime * AngleSwitchSpeed;
            if (y > ShoulderOffGoal.y)
            {
                y = ShoulderOffGoal.y;
            }
        }
        if (z > ShoulderOffGoal.z)
        {
            z -= Time.deltaTime * AngleSwitchSpeed;
            if (z < ShoulderOffGoal.z)
            {
                z = ShoulderOffGoal.z;
            }
        }
        else if (z < ShoulderOffGoal.z)
        {
            z += Time.deltaTime * AngleSwitchSpeed;
            if (z > ShoulderOffGoal.z)
            {
                z = ShoulderOffGoal.z;
            }
        }
        if (x == shoulderOffset.x && y == shoulderOffset.y && z == shoulderOffset.z) {
            AngleSwitching = false;
        }
        cinemachine3rdPersonFollow.ShoulderOffset = new Vector3 (x, y, z);
    }

}
