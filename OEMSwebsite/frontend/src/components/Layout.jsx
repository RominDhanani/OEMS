import React, { useState, useEffect } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { FaUserCircle, FaEdit, FaSignOutAlt, FaWallet, FaHome, FaChevronRight, FaIndent, FaOutdent, FaBars, FaTimes, FaArrowLeft, FaBriefcase } from 'react-icons/fa';
import NotificationDropdown from './NotificationDropdown';

const Layout = ({ children, title, menuItems = [], activeItem, onMenuItemClick }) => {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);
  const [isCollapsed, setIsCollapsed] = useState(false);
  const [isMobile, setIsMobile] = useState(window.innerWidth <= 768);
  const [isSmallScreen, setIsSmallScreen] = useState(window.innerWidth <= 568);
  const [imageError, setImageError] = useState(false);

  const [expandedMenus, setExpandedMenus] = useState({});

  useEffect(() => {
    const handleResize = () => {
      setIsMobile(window.innerWidth <= 768);
      setIsSmallScreen(window.innerWidth <= 568);
    };
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  useEffect(() => {
    // Automatically expand the menu containing the active sub-item
    if (activeItem && menuItems) {
      menuItems.forEach(item => {
        if (item.subItems && item.subItems.some(sub => sub.id === activeItem)) {
          setExpandedMenus(prev => ({ ...prev, [item.id]: true }));
        }
      });
    }
  }, [activeItem, menuItems]);

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const toggleSidebar = () => {
    if (isMobile) {
      setIsSidebarOpen(!isSidebarOpen);
    } else {
      setIsCollapsed(!isCollapsed);
    }
  };

  const toggleMenu = (menuId) => {
    setExpandedMenus(prev => ({
      ...prev,
      [menuId]: !prev[menuId]
    }));
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'row', height: '100vh', overflow: 'hidden' }}>
      {/* Mobile Overlay */}
      <div
        className={`sidebar-overlay ${isSidebarOpen ? 'open' : ''}`}
        onClick={() => setIsSidebarOpen(false)}
      />

      {/* Sidebar - top level flex child */}
      <div className={`sidebar-container ${isSidebarOpen ? 'open' : ''} ${isCollapsed && !isMobile ? 'collapsed' : ''}`}>
        <div className={`sidebar-header ${isCollapsed && !isMobile ? 'collapsed' : ''}`}>
          {isCollapsed && !isMobile ? (
            <div className="brand-icon-only">
              <FaBriefcase />
            </div>
          ) : (
            <div className="brand-full">
              <div className="brand-icon">
                <FaBriefcase />
              </div>
              <div className="brand-text">
                <span className="brand-title">OFFICE EXPENSE</span>
                <span className="brand-subtitle">MANAGEMENT</span>
              </div>
            </div>
          )}

          <button
            className="hamburger-btn mobile-only"
            onClick={() => setIsSidebarOpen(false)}
            style={{ position: 'relative', top: 'auto', right: '0', marginLeft: 'auto', padding: '0.5rem' }}
          >
            <FaTimes />
          </button>
        </div>

        <div className="sidebar-menu">
          {menuItems.map(item => {
            const hasSubItems = item.subItems && item.subItems.length > 0;
            const isExpanded = !!expandedMenus[item.id];

            return (
              <React.Fragment key={item.id}>
                <button
                  onClick={() => {
                    if (isCollapsed && !isMobile && hasSubItems) {
                      setIsCollapsed(false);
                      setTimeout(() => toggleMenu(item.id), 50);
                      return;
                    }

                    if (hasSubItems) {
                      toggleMenu(item.id);
                    } else {
                      onMenuItemClick && onMenuItemClick(item.id);
                      setIsSidebarOpen(false);
                    }
                  }}
                  className={`sidebar-item ${activeItem === item.id || (hasSubItems && item.subItems.some(sub => sub.id === activeItem)) ? 'active' : ''}`}
                  title={isCollapsed && !isMobile ? item.label : ''}
                >
                  {item.icon && <span className="sidebar-icon">{item.icon}</span>}
                  {!(isCollapsed && !isMobile) && (
                    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', width: '100%' }}>
                      <span>{item.label}</span>
                      {hasSubItems && (
                        <FaChevronRight style={{
                          fontSize: '0.7rem',
                          transform: isExpanded ? 'rotate(90deg)' : 'none',
                          transition: 'transform 0.2s'
                        }} />
                      )}
                    </div>
                  )}
                </button>
                {hasSubItems && isExpanded && !(isCollapsed && !isMobile) && (
                  <div className="sidebar-sub-menu">
                    {item.subItems.map(sub => (
                      <button
                        key={sub.id}
                        onClick={() => {
                          onMenuItemClick && onMenuItemClick(sub.id);
                          setIsSidebarOpen(false);
                        }}
                        className={`sidebar-item sub-item ${activeItem === sub.id ? 'active' : ''}`}
                      >
                        {sub.icon && <span className="sub-icon">{sub.icon}</span>}
                        <span>{sub.label}</span>
                      </button>
                    ))}
                  </div>
                )}
              </React.Fragment>
            );
          })}
        </div>

        {/* Sidebar Footer (Profile Card) */}
        <div style={{ padding: '0', marginTop: 'auto', borderTop: '1px solid var(--border-light)' }} className="sidebar-footer">
          {isCollapsed && !isMobile ? (
            <div style={{ padding: '1rem', display: 'flex', justifyContent: 'center' }}>
              <button
                onClick={handleLogout}
                className="logout-btn-red"
                title="Logout"
              >
                <FaSignOutAlt />
              </button>
            </div>
          ) : (
            <div className="profile-card">
              <div
                className="profile-info"
                onClick={() => onMenuItemClick && onMenuItemClick('profile')}
                style={{ cursor: 'pointer' }}
                title="View Profile"
              >
                {user?.profile_image && !imageError ? (
                  <img
                    src={`https://oems-backend.vercel.app${user.profile_image.startsWith('/') ? '' : '/'}${user.profile_image.replace(/\\/g, '/')}`}
                    alt="Profile"
                    className="profile-avatar-small"
                    onError={() => setImageError(true)}
                  />
                ) : (
                  <div className="profile-avatar-placeholder-small">
                    {user?.full_name?.charAt(0).toUpperCase() || <FaUserCircle />}
                  </div>
                )}
                <div className="profile-text">
                  <span className="profile-name">{user?.full_name || 'User'}</span>
                  <span className="profile-email" title={user?.email}>{user?.email || 'email@example.com'}</span>
                </div>
              </div>
              <button
                onClick={handleLogout}
                className="logout-btn-red"
                title="Logout"
              >
                <FaSignOutAlt />
              </button>
            </div>
          )}
        </div>
      </div>

      {/* Main Content Wrapper (Navbar + Page) -> Flex Column */}
      <div style={{ display: 'flex', flexDirection: 'column', flex: 1, height: '100%', overflow: 'hidden', position: 'relative' }}>
        {/* Navbar */}
        <nav className="app-navbar">
          <div className="app-brand" style={{ display: 'flex', alignItems: 'center', gap: '1.5rem' }}>
            <button
              className="hamburger-btn"
              onClick={toggleSidebar}
              style={{
                background: 'none',
                border: 'none',
                cursor: 'pointer',
                color: 'var(--secondary-500)',
                fontSize: '1.25rem',
                display: 'flex',
                alignItems: 'center',
                padding: '0'
              }}
              title={isCollapsed ? "Expand Sidebar" : "Collapse Sidebar"}
            >
              {isMobile || isCollapsed ? <FaBars /> : <FaOutdent />}
            </button>

            <div style={{ width: '1px', height: '24px', background: 'var(--secondary-300)' }}></div>

            <div className="breadcrumb" style={{ display: 'flex', alignItems: 'center', gap: '0.6rem', color: 'var(--primary-600)', fontSize: '1rem', fontWeight: '600' }}>
              {(() => {
                const parentItem = menuItems.find(item =>
                  item.id === activeItem ||
                  (item.subItems && item.subItems.some(sub => sub.id === activeItem))
                );

                if (!parentItem) return <span>Overview</span>;

                const subItem = parentItem.subItems?.find(sub => sub.id === activeItem);

                if (isSmallScreen) {
                  return (
                    <span style={{ color: 'var(--primary-600)', fontWeight: '600' }}>
                      {subItem ? subItem.label : parentItem.label}
                    </span>
                  );
                }

                return (
                  <>
                    {parentItem.icon && (
                      <span style={{ fontSize: '1.1rem', display: 'flex', alignItems: 'center', opacity: 0.9 }}>
                        {parentItem.icon}
                      </span>
                    )}
                    <span style={{ color: subItem ? 'var(--secondary-500)' : 'inherit', fontWeight: subItem ? '500' : '600' }}>
                      {parentItem.label}
                    </span>
                    {subItem && (
                      <>
                        <FaChevronRight style={{ fontSize: '0.7rem', opacity: 0.5 }} />
                        <span style={{ color: 'var(--primary-600)', fontWeight: '600' }}>
                          {subItem.label}
                        </span>
                      </>
                    )}
                  </>
                );
              })()}
            </div>
          </div>
          <div className="navbar-actions" style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
            <NotificationDropdown />
            {/* Profile moved to sidebar footer */}
          </div>
        </nav>

        {/* Page Content Scroller */}
        <div className="main-content" style={{ flex: 1, overflowY: 'auto' }}>
          <div className="page-content page-enter-active" key={location.pathname}>
            {children}
          </div>
        </div>
      </div >
    </div >
  );
};

export default Layout;

